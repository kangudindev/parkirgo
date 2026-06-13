<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { Link } from "@inertiajs/vue3";

const currency = new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 });

export default {
  components: { Layout, PageHeader, Link },
  props: {
    summary: { type: Object, default: () => ({}) },
    zones: { type: Array, default: () => [] },
    recentSessions: { type: Array, default: () => [] },
    recentTransactions: { type: Array, default: () => [] },
  },
  methods: {
    money(value) {
      return currency.format(Number(value || 0));
    },
    statusClass(status) {
      return {
        active: "success",
        paid: "success",
        unpaid: "warning",
        recorded: "info",
        verified: "primary",
        exited: "secondary",
      }[status] || "dark";
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Command Center" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 overflow-hidden parkirgo-hero-card text-white">
          <BCardBody>
            <div class="d-flex align-items-start justify-content-between">
              <div>
                <p class="text-white-75 mb-2">Pendapatan Hari Ini</p>
                <h3 class="text-white mb-1">{{ money(summary.revenue_today) }}</h3>
                <span class="badge bg-white text-success">Live Ops</span>
              </div>
              <div class="avatar-sm rounded-circle bg-white bg-opacity-25 d-flex align-items-center justify-content-center">
                <i class="ri-wallet-3-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 shadow-sm">
          <BCardBody>
            <div class="d-flex justify-content-between">
              <div>
                <p class="text-muted mb-1">Sesi Aktif</p>
                <h3 class="mb-0">{{ summary.active_sessions || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-parking-box-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 shadow-sm">
          <BCardBody>
            <div class="d-flex justify-content-between">
              <div>
                <p class="text-muted mb-1">Zona Aktif</p>
                <h3 class="mb-0">{{ summary.zones_active || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-success-subtle text-success d-flex align-items-center justify-content-center">
                <i class="ri-map-pin-2-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 shadow-sm">
          <BCardBody>
            <div class="d-flex justify-content-between">
              <div>
                <p class="text-muted mb-1">QRIS Menunggu</p>
                <h3 class="mb-0">{{ summary.pending_qris || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-warning-subtle text-warning d-flex align-items-center justify-content-center">
                <i class="ri-qr-code-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BRow>
      <BCol xl="8">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader class="align-items-center d-flex">
            <BCardTitle class="mb-0 flex-grow-1">Radar Zona</BCardTitle>
            <Link href="/parkirgo/zones" class="btn btn-sm btn-soft-primary">Kelola Zona</Link>
          </BCardHeader>
          <BCardBody>
            <div class="table-responsive table-card">
              <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Zona</th>
                    <th>Kota</th>
                    <th>Sesi Aktif</th>
                    <th>Pendapatan</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="zone in zones" :key="zone.id">
                    <td>
                      <div class="fw-semibold">{{ zone.name }}</div>
                      <small class="text-muted">{{ zone.code }}</small>
                    </td>
                    <td>{{ zone.city || '-' }}</td>
                    <td>{{ zone.active_sessions_count || 0 }}</td>
                    <td>{{ money(zone.revenue_sum) }}</td>
                    <td><span class="badge bg-success-subtle text-success">{{ zone.status }}</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="4">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader>
            <BCardTitle class="mb-0">Transaksi Terbaru</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div v-for="trx in recentTransactions" :key="trx.id" class="d-flex align-items-center border-bottom pb-3 mb-3">
              <div class="avatar-xs me-3 rounded-circle bg-info-subtle text-info d-flex align-items-center justify-content-center">
                <i class="ri-bank-card-line"></i>
              </div>
              <div class="flex-grow-1">
                <h6 class="mb-1">{{ trx.transaction_number }}</h6>
                <p class="text-muted mb-0">{{ trx.zone?.name }} · {{ trx.payment_method }}</p>
              </div>
              <div class="text-end">
                <div class="fw-semibold">{{ money(trx.amount) }}</div>
                <span class="badge" :class="`bg-${statusClass(trx.status)}-subtle text-${statusClass(trx.status)}`">{{ trx.status }}</span>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>
  </Layout>
</template>

<style scoped>
.parkirgo-hero-card {
  background: linear-gradient(135deg, #0f9f6e, #0ea5e9 55%, #4f46e5);
  box-shadow: 0 18px 45px rgba(14, 165, 233, 0.22);
}
.text-white-75 { color: rgba(255,255,255,.75); }
</style>
