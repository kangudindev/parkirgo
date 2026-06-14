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

// GET /api/transactions - List transactions
export async function GET(request: NextRequest) {
  try {
    const { authorized } = await requireAuth();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '20');
    const zoneId = searchParams.get('zoneId');
    const status = searchParams.get('status');
    const paymentMethod = searchParams.get('paymentMethod');
    const dateFrom = searchParams.get('dateFrom');
    const dateTo = searchParams.get('dateTo');
    const jukirId = searchParams.get('jukirId');
    
    const where: Record<string, unknown> = {};
    
    if (zoneId) where.zoneId = zoneId;
    if (status) where.paymentStatus = status;
    if (paymentMethod) where.paymentMethod = paymentMethod;
    if (jukirId) {
      where.session = { jukirId };
    }
    
    if (dateFrom || dateTo) {
      where.transactionTime = {};
      if (dateFrom) {
        (where.transactionTime as Record<string, Date>).gte = new Date(`${dateFrom}T00:00:00.000Z`);
      }
      if (dateTo) {
        (where.transactionTime as Record<string, Date>).lte = new Date(`${dateTo}T23:59:59.999Z`);
      }
    }
    
    const [transactions, total] = await Promise.all([
      prisma.transaction.findMany({
        where,
        include: {
          session: {
            select: {
              id: true,
              vehiclePlate: true,
              vehicleType: true,
              zoneId: true,
              zone: {
                select: {
                  name: true,
                },
              },
            },
          },
          shift: {
            select: {
              id: true,
              user: {
                select: {
                  id: true,
                  name: true,
                  nik: true,
                },
              },
            },
          },
          verifiedBy: {
            select: {
              id: true,
              name: true,
            },
          },
        },
        orderBy: { transactionTime: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.transaction.count({ where }),
    ]);
    
    return NextResponse.json({
      success: true,
      data: transactions,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Error fetching transactions:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}

// PATCH /api/transactions - Verify/Reject transaction
export async function PATCH(request: NextRequest) {
  try {
    const { authorized, user } = await requireAuth();
    if (!authorized) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const body = await request.json();
    const { transactionId, action } = body; // action: 'verify' | 'reject'
    
    if (!transactionId || !action) {
      return NextResponse.json(
        { success: false, error: 'ID transaksi dan aksi wajib diisi' },
        { status: 400 }
      );
    }
    
    if (!['verify', 'reject'].includes(action)) {
      return NextResponse.json(
        { success: false, error: 'Aksi tidak valid' },
        { status: 400 }
      );
    }
    
    const transaction = await prisma.transaction.findUnique({
      where: { id: transactionId },
    });
    
    if (!transaction) {
      return NextResponse.json(
        { success: false, error: 'Transaksi tidak ditemukan' },
        { status: 404 }
      );
    }
    
    if (transaction.paymentStatus !== 'recorded') {
      return NextResponse.json(
        { success: false, error: 'Transaksi sudah diproses sebelumnya' },
        { status: 400 }
      );
    }
    
    const updated = await prisma.transaction.update({
      where: { id: transactionId },
      data: {
        paymentStatus: action === 'verify' ? 'verified' : 'rejected',
        verificationBy: user?.id,
        verificationAt: new Date(),
      },
    });
    
    // Audit log
    await prisma.auditLog.create({
      data: {
        userId: user?.id,
        action: action === 'verify' ? 'VERIFY_TRANSACTION' : 'REJECT_TRANSACTION',
        entityType: 'Transaction',
        entityId: transactionId,
        oldValues: transaction,
        newValues: updated,
        ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
      },
    });
    
    return NextResponse.json({ 
      success: true, 
      message: `Transaksi berhasil di${action === 'verify' ? 'verifikasi' : 'tolak'}`,
      data: updated 
    });
  } catch (error) {
    console.error('Error updating transaction:', error);
    return NextResponse.json(
      { success: false, error: 'Terjadi kesalahan server' },
      { status: 500 }
    );
  }
}