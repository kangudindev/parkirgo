import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser, hashPassword } from '@/server/auth/auth';
import prisma from '@/server/db/prisma';

interface RouteParams {
  params: Promise<{ id: string }>;
}

async function requireAdmin() {
  const user = await getCurrentUser();
  if (!user || user.role !== 'admin') {
    return { authorized: false };
  }
  return { authorized: true, user };
}

// GET /api/users/[id]
export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    
    const user = await prisma.user.findUnique({
      where: { id },
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
    });
    
    if (!user) {
      return NextResponse.json(
        { success: false, error: 'Pengguna tidak ditemukan' },
        { status: 404 }
      );
    }
    
    return NextResponse.json({ success: true, data: user });
  } catch (error) {
    console.error('Error fetching user:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// PUT /api/users/[id]
export async function PUT(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized, user: currentUser } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    const body = await request.json();
    
    const existing = await prisma.user.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json(
        { success: false, error: 'Pengguna tidak ditemukan' },
        { status: 404 }
      );
    }
    
    const updateData: Record<string, unknown> = {};
    
    if (body.name !== undefined) updateData.name = body.name;
    if (body.email !== undefined) updateData.email = body.email;
    if (body.phone !== undefined) updateData.phone = body.phone;
    if (body.role !== undefined) updateData.role = body.role;
    if (body.zoneId !== undefined) updateData.zoneId = body.zoneId;
    if (body.photo !== undefined) updateData.photo = body.photo;
    if (body.status !== undefined) updateData.status = body.status;
    
    // Handle password change
    if (body.password) {
      updateData.password = await hashPassword(body.password);
    }
    
    const user = await prisma.user.update({
      where: { id },
      data: updateData,
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
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: currentUser?.id,
        action: 'UPDATE',
        entityType: 'User',
        entityId: user.id,
        oldValues: existing,
        newValues: { ...user, password: body.password ? '[CHANGED]' : '[UNCHANGED]' },
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, data: user });
  } catch (error) {
    console.error('Error updating user:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// DELETE /api/users/[id]
export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized, user: currentUser } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    const { searchParams } = new URL(request.url);
    const requestingUserId = searchParams.get('userId');
    
    // Prevent self-deletion
    if (id === currentUser?.id) {
      return NextResponse.json(
        { success: false, error: 'Tidak dapat menghapus akun sendiri' },
        { status: 400 }
      );
    }
    
    const existing = await prisma.user.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json(
        { success: false, error: 'Pengguna tidak ditemukan' },
        { status: 404 }
      );
    }
    
    await prisma.user.delete({ where: { id } });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: requestingUserId,
        action: 'DELETE',
        entityType: 'User',
        entityId: id,
        oldValues: existing,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, message: 'Pengguna berhasil dihapus' });
  } catch (error) {
    console.error('Error deleting user:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// POST /api/users/[id]/reset-password
export async function PATCH(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized, user: currentUser } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    const body = await request.json();
    
    const existing = await prisma.user.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json(
        { success: false, error: 'Pengguna tidak ditemukan' },
        { status: 404 }
      );
    }
    
    // Reset password to default (123456)
    const defaultPassword = await hashPassword('123456');
    
    await prisma.user.update({
      where: { id },
      data: {
        password: defaultPassword,
        failedLoginAttempts: 0,
        lockedUntil: null,
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: currentUser?.id,
        action: 'RESET_PASSWORD',
        entityType: 'User',
        entityId: id,
        oldValues: existing,
        newValues: { passwordReset: true },
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ 
      success: true, 
      message: 'Password berhasil direset ke default: 123456' 
    });
  } catch (error) {
    console.error('Error resetting password:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}