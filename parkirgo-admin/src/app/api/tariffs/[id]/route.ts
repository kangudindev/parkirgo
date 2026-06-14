import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser } from '@/server/auth/auth';
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

// GET /api/tariffs/[id]
export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    
    const tariff = await prisma.zoneTariff.findUnique({
      where: { id },
      include: {
        zone: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });
    
    if (!tariff) {
      return NextResponse.json(
        { success: false, error: 'Tarif tidak ditemukan' },
        { status: 404 }
      );
    }
    
    return NextResponse.json({ success: true, data: tariff });
  } catch (error) {
    console.error('Error fetching tariff:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// PUT /api/tariffs/[id]
export async function PUT(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized, user } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    const body = await request.json();
    
    const existing = await prisma.zoneTariff.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json(
        { success: false, error: 'Tarif tidak ditemukan' },
        { status: 404 }
      );
    }
    
    const tariff = await prisma.zoneTariff.update({
      where: { id },
      data: {
        pricingType: body.pricingType,
        paymentTiming: body.paymentTiming,
        flatRate: body.flatRate,
        progressiveRate: body.progressiveRate,
        maxDaily: body.maxDaily,
        gracePeriodMinutes: body.gracePeriodMinutes,
        roundingStrategy: body.roundingStrategy,
        startHour: body.startHour,
        endHour: body.endHour,
        isActive: body.isActive,
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: user?.id,
        action: 'UPDATE',
        entityType: 'ZoneTariff',
        entityId: tariff.id,
        oldValues: existing,
        newValues: tariff,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, data: tariff });
  } catch (error) {
    console.error('Error updating tariff:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// DELETE /api/tariffs/[id]
export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const { authorized, user } = await requireAdmin();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { id } = await params;
    
    const existing = await prisma.zoneTariff.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json(
        { success: false, error: 'Tarif tidak ditemukan' },
        { status: 404 }
      );
    }
    
    await prisma.zoneTariff.delete({ where: { id } });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: user?.id,
        action: 'DELETE',
        entityType: 'ZoneTariff',
        entityId: id,
        oldValues: existing,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ success: true, message: 'Tarif berhasil dihapus' });
  } catch (error) {
    console.error('Error deleting tariff:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}