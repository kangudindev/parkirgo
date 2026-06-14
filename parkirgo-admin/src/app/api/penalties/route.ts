import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser } from '@/server/auth/auth';
import prisma from '@/server/db/prisma';

async function requireAdmin() {
  const user = await getCurrentUser();
  if (!user || user.role !== 'admin') {
    return { authorized: false };
  }
  return { authorized: true, user };
}

// GET /api/penalties
export async function GET(request: NextRequest) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { searchParams } = new URL(request.url);
    const zoneId = searchParams.get('zoneId');
    
    const where = zoneId ? { zoneId } : {};
    
    const penalties = await prisma.zonePenalty.findMany({
      where,
      include: {
        zone: {
          select: {
            id: true,
            name: true,
          },
        },
      },
      orderBy: [
        { zone: { name: 'asc' } },
        { penaltyType: 'asc' },
      ],
    });
    
    return NextResponse.json({ success: true, data: penalties });
  } catch (error) {
    console.error('Error fetching penalties:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// POST /api/penalties
export async function POST(request: NextRequest) {
  try {
    const { authorized, user } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const body = await request.json();
    const { zoneId, vehicleType, penaltyType, amount } = body;
    
    if (!zoneId || !penaltyType || amount === undefined) {
      return NextResponse.json(
        { success: false, error: 'Zone, tipe denda, dan nominal wajib diisi' },
        { status: 400 }
      );
    }
    
    const penalty = await prisma.zonePenalty.create({
      data: {
        zoneId,
        vehicleType: vehicleType || null,
        penaltyType,
        amount,
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: user?.id,
        action: 'CREATE',
        entityType: 'ZonePenalty',
        entityId: penalty.id,
        newValues: penalty,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, data: penalty }, { status: 201 });
  } catch (error) {
    console.error('Error creating penalty:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}