import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser } from '@/server/auth/auth';
import prisma from '@/server/db/prisma';

// Require admin authentication
async function requireAdmin() {
  const user = await getCurrentUser();
  if (!user || user.role !== 'admin') {
    return { authorized: false };
  }
  return { authorized: true, user };
}

// GET /api/zones - List all zones
export async function GET(request: NextRequest) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { searchParams } = new URL(request.url);
    const isActive = searchParams.get('isActive');
    
    const where = isActive !== null ? { isActive: isActive === 'true' } : {};
    
    const zones = await prisma.zone.findMany({
      where,
      include: {
        _count: {
          select: {
            users: true,
            parkingSessions: true,
          },
        },
      },
      orderBy: { name: 'asc' },
    });
    
    return NextResponse.json({ success: true, data: zones });
  } catch (error) {
    console.error('Error fetching zones:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// POST /api/zones - Create new zone
export async function POST(request: NextRequest) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const body = await request.json();
    const { name, city, polygonCoordinates, capacity, qrisImage, qrisPayload, qrisMerchantName, qrisIsActive } = body;
    
    if (!name) {
      return NextResponse.json(
        { success: false, error: 'Nama zona wajib diisi' },
        { status: 400 }
      );
    }
    
    const zone = await prisma.zone.create({
      data: {
        name,
        city,
        polygonCoordinates,
        capacity,
        qrisImage,
        qrisPayload,
        qrisMerchantName,
        qrisIsActive: qrisIsActive || false,
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: body.user?.id,
        action: 'CREATE',
        entityType: 'Zone',
        entityId: zone.id,
        newValues: zone,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, data: zone }, { status: 201 });
  } catch (error) {
    console.error('Error creating zone:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}