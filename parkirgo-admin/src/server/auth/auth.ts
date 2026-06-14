import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { cookies } from 'next/headers';
import prisma from '@/server/db/prisma';

const JWT_SECRET = process.env.JWT_SECRET || 'default-secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '8h';

export interface JWTPayload {
  userId: string;
  nik: string;
  role: string;
}

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 12);
}

export async function verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
  return bcrypt.compare(password, hashedPassword);
}

export function generateToken(payload: JWTPayload): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

export function verifyToken(token: string): JWTPayload | null {
  try {
    return jwt.verify(token, JWT_SECRET) as JWTPayload;
  } catch {
    return null;
  }
}

export async function getCurrentUser() {
  try {
    const cookieStore = await cookies();
    const token = cookieStore.get('auth_token')?.value;
    
    if (!token) return null;
    
    const payload = verifyToken(token);
    if (!payload) return null;
    
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: {
        id: true,
        nik: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        zoneId: true,
        photo: true,
        status: true,
        zone: {
          select: {
            id: true,
            name: true,
            city: true,
          },
        },
      },
    });
    
    if (!user || user.status !== 'active') return null;
    
    return user;
  } catch {
    return null;
  }
}

export async function login(nik: string, password: string) {
  const user = await prisma.user.findUnique({
    where: { nik },
  });
  
  if (!user) {
    return { success: false, error: 'NIK atau password salah' };
  }
  
  // Check if account is locked
  if (user.lockedUntil && user.lockedUntil > new Date()) {
    const remainingMinutes = Math.ceil((user.lockedUntil.getTime() - Date.now()) / 60000);
    return { 
      success: false, 
      error: `Akun terkunci. Coba lagi dalam ${remainingMinutes} menit` 
    };
  }
  
  const isValid = await verifyPassword(password, user.password);
  
  if (!isValid) {
    // Increment failed login attempts
    const newAttempts = user.failedLoginAttempts + 1;
    const updates: { failedLoginAttempts: number; lockedUntil?: Date } = {
      failedLoginAttempts: newAttempts,
    };
    
    // Lock account after 3 failed attempts
    if (newAttempts >= 3) {
      updates.lockedUntil = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
    }
    
    await prisma.user.update({
      where: { id: user.id },
      data: updates,
    });
    
    return { 
      success: false, 
      error: newAttempts >= 3 
        ? 'Terlalu banyak percobaan login. Akun terkunci 15 menit' 
        : 'NIK atau password salah' 
    };
  }
  
  // Reset failed attempts on successful login
  await prisma.user.update({
    where: { id: user.id },
    data: {
      failedLoginAttempts: 0,
      lockedUntil: null,
      lastLogin: new Date(),
    },
  });
  
  const token = generateToken({
    userId: user.id,
    nik: user.nik,
    role: user.role,
  });
  
  return {
    success: true,
    token,
    user: {
      id: user.id,
      nik: user.nik,
      name: user.name,
      role: user.role,
      zoneId: user.zoneId,
      photo: user.photo,
    },
  };
}

export async function logout() {
  const cookieStore = await cookies();
  cookieStore.delete('auth_token');
  return { success: true };
}