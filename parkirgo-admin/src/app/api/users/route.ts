import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser, hashPassword } from '@/server/auth/auth';
import prisma from '@/server/db/prisma';

// Require admin authentication
async function requireAdmin() {
  const user = await getCurrentUser();
  if (!user || user.role !== 'admin') {
    return { authorized: false };
  }
  return { authorized: true, user };
}

// GET /api/users - List all users
export async function GET(request: NextRequest) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { searchParams } = new URL(request.url);
    const role = searchParams.get('role');
    const zoneId = searchParams.get('zoneId');
    const status = searchParams.get('status');
    
    const where: Record<string, unknown> = {};
    if (role) where.role = role;
    if (zoneId) where.zoneId = zoneId;
    if (status) where.status = status;
    
    const users = await prisma.user.findMany({
      where,
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
        lastLogin: true,
        createdAt: true,
        zone: {
          select: {
            id: true,
            name: true,
            city: true,
          },
        },
      },
      orderBy: { name: 'asc' },
    });
    
    return NextResponse.json({ success: true, data: users });
  } catch (error) {
    console.error('Error fetching users:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// POST /api/users - Create new user
export async function POST(request: NextRequest) {
  try {
    const { authorized, user: currentUser } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const body = await request.json();
    const { nik, name, email, phone, password, role, zoneId, photo } = body;
    
    // Validation
    if (!nik || !name || !password || !role) {
      return NextResponse.json(
        { success: false, error: 'NIK, nama, password, dan role wajib diisi' },
        { status: 400 }
      );
    }
    
    // Check if NIK already exists
    const existing = await prisma.user.findUnique({ where: { nik } });
    if (existing) {
      return NextResponse.json(
        { success: false, error: 'NIK sudah terdaftar' },
        { status: 400 }
      );
    }
    
    const hashedPassword = await hashPassword(password);
    
    const newUser = await prisma.user.create({
      data: {
        nik,
        name,
        email,
        phone,
        password: hashedPassword,
        role,
        zoneId,
        photo,
      },
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
        createdAt: true,
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: currentUser?.id,
        action: 'CREATE',
        entityType: 'User',
        entityId: newUser.id,
        newValues: { ...newUser, password: '[REDACTED]' },
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, data: newUser }, { status: 201 });
  } catch (error) {
    console.error('Error creating user:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}