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

// GET /api/tariffs - List all tariffs
export async function GET(request: NextRequest) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { searchParams } = new URL(request.url);
    const zoneId = searchParams.get('zoneId');
    
    const where = zoneId ? { zoneId } : {};
    
    const tariffs = await prisma.zoneTariff.findMany({
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
        { vehicleType: 'asc' },
      ],
    });
    
    return NextResponse.json({ success: true, data: tariffs });
  } catch (error) {
    console.error('Error fetching tariffs:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// POST /api/tariffs - Create new tariff
export async function POST(request: NextRequest) {
  try {
    const { authorized, user } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const body = await request.json();
    const { 
      zoneId, vehicleType, pricingType, paymentTiming,
      flatRate, progressiveRate, maxDaily, gracePeriodMinutes,
      roundingStrategy, startHour, endHour 
    } = body;
    
    if (!zoneId || !vehicleType || !pricingType) {
      return NextResponse.json(
        { success: false, error: 'Zone, jenis kendaraan, dan tipe tarif wajib diisi' },
        { status: 400 }
      );
    }
    
    // Check if tariff already exists for this zone + vehicle type
    const existing = await prisma.zoneTariff.findFirst({
      where: { zoneId, vehicleType },
    });
    
    if (existing) {
      return NextResponse.json(
        { success: false, error: 'Tarif untuk zona dan jenis kendaraan ini sudah ada. Gunakan edit untuk mengubah.' },
        { status: 400 }
      );
    }
    
    const tariff = await prisma.zoneTariff.create({
      data: {
        zoneId,
        vehicleType,
        pricingType,
        paymentTiming: paymentTiming || 'exit',
        flatRate,
        progressiveRate,
        maxDaily,
        gracePeriodMinutes: gracePeriodMinutes || 0,
        roundingStrategy: roundingStrategy || 'nearest',
        startHour,
        endHour,
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: user?.id,
        action: 'CREATE',
        entityType: 'ZoneTariff',
        entityId: tariff.id,
        newValues: tariff,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, data: tariff }, { status: 201 });
  } catch (error) {
    console.error('Error creating tariff:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}