import { NextRequest, NextResponse } from 'next/server';
import { getCurrentUser } from '@/server/auth/auth';
import prisma from '@/server/db/prisma';
import { Prisma } from '@prisma/client';

async function requireAuth() {
  const user = await getCurrentUser();
  if (!user) {
    return { authorized: false };
  }
  return { authorized: true, user };
}

// GET /api/dashboard - Main dashboard data
export async function GET(request: NextRequest) {
  try {
    const { authorized, user } = await requireAuth();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date') || new Date().toISOString().split('T')[0];
    const zoneId = searchParams.get('zoneId');
    
    const startOfDay = new Date(`${date}T00:00:00.000Z`);
    const endOfDay = new Date(`${date}T23:59:59.999Z`);
    
    // Base filter
    const dateFilter = {
      transactionTime: {
        gte: startOfDay,
        lte: endOfDay,
      },
    };
    
    const zoneFilter = zoneId ? { zoneId } : {};
    
    // Today's summary
    const [todayTransactions, activeSessions, totalJukir, zones] = await Promise.all([
      // Today's transactions
      prisma.transaction.aggregate({
        where: {
          ...dateFilter,
          ...zoneFilter,
        },
        _count: true,
        _sum: {
          amount: true,
        },
      }),
      
      // Active parking sessions
      prisma.parkingSession.count({
        where: {
          status: 'active',
          ...(zoneId ? { zoneId } : {}),
        },
      }),
      
      // Total active jukir
      prisma.user.count({
        where: {
          role: 'jukir',
          status: 'active',
          ...(zoneId ? { zoneId } : {}),
        },
      }),
      
      // Total zones
      prisma.zone.count({
        where: {
          isActive: true,
          ...(zoneId ? { id: zoneId } : {}),
        },
      }),
    ]);
    
    // Payment method breakdown
    const paymentBreakdown = await prisma.transaction.groupBy({
      by: ['paymentMethod'],
      where: {
        ...dateFilter,
        ...zoneFilter,
      },
      _sum: {
        amount: true,
      },
      _count: true,
    });
    
    // Zone performance
    const zonePerformance = await prisma.transaction.groupBy({
      by: ['session', 'zoneId'],
      where: {
        ...dateFilter,
      },
      _sum: {
        amount: true,
      },
    });
    
    // Get zone names for the performance data
    const zoneIds = [...new Set(zonePerformance.map(p => p.zoneId))];
    const zoneDetails = await prisma.zone.findMany({
      where: { id: { in: zoneIds } },
      select: { id: true, name: true },
    });
    
    const zoneMap = new Map(zoneDetails.map(z => [z.id, z.name]));
    
    const zoneStats = zonePerformance.reduce((acc, curr) => {
      const zoneName = zoneMap.get(curr.zoneId) || 'Unknown';
      if (!acc[zoneName]) {
        acc[zoneName] = { total: 0, count: 0 };
      }
      acc[zoneName].total += Number(curr._sum.amount) || 0;
      acc[zoneName].count += 1;
      return acc;
    }, {} as Record<string, { total: number; count: number }>);
    
    // Weekly trend (last 7 days)
    const weeklyTrend = [];
    for (let i = 6; i >= 0; i--) {
      const day = new Date();
      day.setDate(day.getDate() - i);
      const dayStr = day.toISOString().split('T')[0];
      
      const dayStart = new Date(`${dayStr}T00:00:00.000Z`);
      const dayEnd = new Date(`${dayStr}T23:59:59.999Z`);
      
      const dayStats = await prisma.transaction.aggregate({
        where: {
          transactionTime: {
            gte: dayStart,
            lte: dayEnd,
          },
          ...(zoneId ? { zoneId } : {}),
        },
        _sum: {
          amount: true,
        },
        _count: true,
      });
      
      weeklyTrend.push({
        date: dayStr,
        total: Number(dayStats._sum.amount) || 0,
        count: dayStats._count,
      });
    }
    
    // Top performing zones
    const topZones = await prisma.zone.findMany({
      where: {
        isActive: true,
        ...(zoneId ? { id: zoneId } : {}),
      },
      include: {
        _count: {
          select: {
            parkingSessions: {
              where: {
                status: 'completed',
                exitTime: {
                  gte: startOfDay,
                  lte: endOfDay,
                },
              },
            },
          },
        },
        parkingSessions: {
          where: {
            status: 'completed',
            exitTime: {
              gte: startOfDay,
              lte: endOfDay,
            },
          },
          select: {
            totalFee: true,
          },
        },
      },
      take: 5,
    });
    
    const topZonesData = topZones.map(zone => ({
      id: zone.id,
      name: zone.name,
      city: zone.city,
      totalVehicles: zone._count.parkingSessions,
      totalRevenue: zone.parkingSessions.reduce((sum, s) => sum + Number(s.totalFee || 0), 0),
    })).sort((a, b) => b.totalRevenue - a.totalRevenue);
    
    return NextResponse.json({
      success: true,
      data: {
        summary: {
          todayRevenue: Number(todayTransactions._sum.amount) || 0,
          todayTransactions: todayTransactions._count,
          activeSessions,
          totalJukir,
          totalZones: zones,
        },
        paymentBreakdown: {
          cash: paymentBreakdown.find(p => p.paymentMethod === 'cash') || { _sum: { amount: 0 }, _count: 0 },
          qris: paymentBreakdown.find(p => p.paymentMethod === 'qris_static') || { _sum: { amount: 0 }, _count: 0 },
        },
        weeklyTrend,
        topZones: topZonesData,
        zoneStats,
      },
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}