import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser } from '@/server/auth/auth';
import prisma from '@/server/db/prisma';

// Helper to check admin role
async function requireAdmin() {
  const user = await getCurrentUser();
  if (!user || user.role !== 'admin') {
    return { authorized: false, error: 'Unauthorized - Admin only' };
  }
  return { authorized: true, user };
}

// ============================================
// AUTH ROUTES
// ============================================

export async function POST(request: NextRequest) {
  try {
    const { action } = await request.json();
    
    if (action === 'login') {
      const { nik, password } = await request.json();
      
      if (!nik || !password) {
        return NextResponse.json(
          { success: false, error: 'NIK dan password wajib diisi' },
          { status: 400 }
        );
      }
      
      const { login } = await import('@/server/auth/auth');
      const result = await login(nik, password);
      
      if (!result.success) {
        return NextResponse.json(result, { status: 401 });
      }
      
      const response = NextResponse.json(result);
      response.cookies.set('auth_token', result.token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        maxAge: 8 * 60 * 60, // 8 hours
        path: '/',
      });
      
      return response;
    }
    
    if (action === 'logout') {
      const { logout } = await import('@/server/auth/auth');
      await logout();
      return NextResponse.json({ success: true });
    }
    
    return NextResponse.json(
      { success: false, error: 'Invalid action' },
      { status: 400 }
    );
  } catch (error) {
    console.error('Auth error:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

export async function GET() {
  try {
    const user = await getCurrentUser();
    
    if (!user) {
      return NextResponse.json(
        { authenticated: false, user: null },
        { status: 401 }
      );
    }
    
    return NextResponse.json({
      authenticated: true,
      user,
    });
  } catch (error) {
    console.error('Auth check error:', error);
    return NextResponse.json(
      { authenticated: false, error: 'Terjadi kesalahan' },
      { status: 500 }
    );
  }
}