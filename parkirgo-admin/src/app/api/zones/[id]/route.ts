import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser } from '@/server/auth/auth';
import prisma from '@/server/db/prisma';

interface RouteParams {
  params: Promise<{ id: string }>;
}

// Require admin authentication
async function requireAdmin() {
  const user = await getCurrentUser();
  if (!user || user.role !== 'admin') {
    return { authorized: false };
  }
  return { authorized: true, user };
}

// GET /api/zones/[id]
export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    
    const zone = await prisma.zone.findUnique({
      where: { id },
      include: {
        tariffs: true,
        penalties: true,
        _count: {
          select: {
            users: true,
            parkingSessions: true,
          },
        },
      },
    });
    
    if (!zone) {
      return NextResponse.json(
        { success: false, error: 'Zona tidak ditemukan' },
        { status: 404 }
      );
    }
    
    return NextResponse.json({ success: true, data: zone });
  } catch (error) {
    console.error('Error fetching zone:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// PUT /api/zones/[id]
export async function PUT(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    const body = await request.json();
    
    const existing = await prisma.zone.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json(
        { success: false, error: 'Zona tidak ditemukan' },
        { status: 404 }
      );
    }
    
    const zone = await prisma.zone.update({
      where: { id },
      data: {
        name: body.name,
        city: body.city,
        polygonCoordinates: body.polygonCoordinates,
        capacity: body.capacity,
        qrisImage: body.qrisImage,
        qrisPayload: body.qrisPayload,
        qrisMerchantName: body.qrisMerchantName,
        qrisIsActive: body.qrisIsActive,
        isActive: body.isActive,
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: body.userId,
        action: 'UPDATE',
        entityType: 'Zone',
        entityId: zone.id,
        oldValues: existing,
        newValues: zone,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, data: zone });
  } catch (error) {
    console.error('Error updating zone:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// DELETE /api/zones/[id]
export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized, user } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');
    
    const existing = await prisma.zone.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json(
        { success: false, error: 'Zona tidak ditemukan' },
        { status: 404 }
      );
    }
    
    await prisma.zone.delete({ where: { id } });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId,
        action: 'DELETE',
        entityType: 'Zone',
        entityId: id,
        oldValues: existing,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, message: 'Zona berhasil dihapus' });
  } catch (error) {
    console.error('Error deleting zone:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}