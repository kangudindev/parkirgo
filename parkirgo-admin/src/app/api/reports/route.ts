import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser } from '@/server/auth/auth';
import prisma from '@/server/db/prisma';

async function requireAuth() {
  const user = await getCurrentUser();
  if (!user) {
    return { authorized: false };
  }
  return { authorized: true, user };
}

// GET /api/reports - Generate reports
export async function GET(request: NextRequest) {
  try {
    const { authorized } = await requireAuth();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type') || 'daily'; // daily | weekly | monthly
    const dateFrom = searchParams.get('dateFrom');
    const dateTo = searchParams.get('dateTo');
    const zoneId = searchParams.get('zoneId');
    
    // Build date range
    let startDate: Date;
    let endDate: Date = new Date();
    
    if (dateFrom && dateTo) {
      startDate = new Date(`${dateFrom}T00:00:00.000Z`);
      endDate = new Date(`${dateTo}T23:59:59.999Z`);
    } else {
      switch (type) {
        case 'weekly':
          startDate = new Date();
          startDate.setDate(startDate.getDate() - 7);
          break;
        case 'monthly':
          startDate = new Date();
          startDate.setMonth(startDate.getMonth() - 1);
          break;
        default: // daily
          startDate = new Date();
          startDate.setHours(0, 0, 0, 0);
          endDate = new Date();
          endDate.setHours(23, 59, 59, 999);
      }
    }
    
    const whereClause: Record<string, unknown> = {
      transactionTime: {
        gte: startDate,
        lte: endDate,
      },
    };
    
    if (zoneId) whereClause.zoneId = zoneId;
    
    // Summary by payment method
    const paymentSummary = await prisma.transaction.groupBy({
      by: ['paymentMethod', 'paymentStatus'],
      where: whereClause,
      _count: true,
      _sum: {
        amount: true,
      },
    });
    
    // Summary by zone
    const zoneSummary = await prisma.transaction.groupBy({
      by: ['zoneId'],
      where: whereClause,
      _count: true,
      _sum: {
        amount: true,
      },
    });
    
    // Get zone names
    const zoneIds = zoneSummary.map(z => z.zoneId);
    const zones = await prisma.zone.findMany({
      where: { id: { in: zoneIds } },
      select: { id: true, name: true, city: true },
    });
    const zoneMap = new Map(zones.map(z => [z.id, z]));
    
    // Summary by jukir
    const jukirSummary = await prisma.transaction.groupBy({
      by: ['shift'],
      where: whereClause,
      _count: true,
      _sum: {
        amount: true,
      },
    });
    
    // Get shift details
    const shiftIds = jukirSummary.map(s => s.shift).filter(Boolean);
    const shifts = await prisma.shift.findMany({
      where: { id: { in: shiftIds as string[] } },
      include: {
        user: {
          select: { id: true, name: true, nik: true },
        },
      },
    });
    const shiftMap = new Map(shifts.map(s => [s.id, s]));
    
    // Daily breakdown
    const dailyBreakdown = await prisma.transaction.groupBy({
      by: ['transactionTime'],
      where: whereClause,
      _count: true,
      _sum: {
        amount: true,
      },
    });
    
    // Group by date
    const dailyMap = new Map<string, { date: string; total: number; count: number }>();
    dailyBreakdown.forEach(item => {
      const dateStr = new Date(item.transactionTime).toISOString().split('T')[0];
      const existing = dailyMap.get(dateStr) || { date: dateStr, total: 0, count: 0 };
      existing.total += Number(item._sum.amount) || 0;
      existing.count += item._count;
      dailyMap.set(dateStr, existing);
    });
    
    // Total summary
    const totalSummary = await prisma.transaction.aggregate({
      where: whereClause,
      _count: true,
      _sum: {
        amount: true,
      },
    });
    
    // Vehicle type breakdown
    const vehicleSummary = await prisma.parkingSession.groupBy({
      by: ['vehicleType'],
      where: {
        exitTime: {
          gte: startDate,
          lte: endDate,
        },
        ...(zoneId ? { zoneId } : {}),
      },
      _count: true,
    });
    
    return NextResponse.json({
      success: true,
      data: {
        period: {
          type,
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString(),
        },
        summary: {
          totalTransactions: totalSummary._count,
          totalRevenue: Number(totalSummary._sum.amount) || 0,
        },
        paymentBreakdown: {
          cash: {
            recorded: paymentSummary.find(p => p.paymentMethod === 'cash' && p.paymentStatus === 'recorded'),
            verified: paymentSummary.find(p => p.paymentMethod === 'cash' && p.paymentStatus === 'verified'),
            rejected: paymentSummary.find(p => p.paymentMethod === 'cash' && p.paymentStatus === 'rejected'),
          },
          qris: {
            recorded: paymentSummary.find(p => p.paymentMethod === 'qris_static' && p.paymentStatus === 'recorded'),
            verified: paymentSummary.find(p => p.paymentMethod === 'qris_static' && p.paymentStatus === 'verified'),
            rejected: paymentSummary.find(p => p.paymentMethod === 'qris_static' && p.paymentStatus === 'rejected'),
          },
        },
        zoneBreakdown: zoneSummary.map(z => ({
          zoneId: z.zoneId,
          zoneName: zoneMap.get(z.zoneId)?.name || 'Unknown',
          zoneCity: zoneMap.get(z.zoneId)?.city,
          transactions: z._count,
          revenue: Number(z._sum.amount) || 0,
        })),
        jukirBreakdown: jukirSummary.map(j => ({
          shiftId: j.shift,
          jukirName: shiftMap.get(j.shift as string)?.user?.name || 'Unknown',
          jukirNik: shiftMap.get(j.shift as string)?.user?.nik,
          transactions: j._count,
          revenue: Number(j._sum.amount) || 0,
        })),
        vehicleBreakdown: vehicleSummary.map(v => ({
          vehicleType: v.vehicleType,
          count: v._count,
        })),
        dailyBreakdown: Array.from(dailyMap.values()).sort((a, b) => a.date.localeCompare(b.date)),
      },
    });
  } catch (error) {
    console.error('Error generating report:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}