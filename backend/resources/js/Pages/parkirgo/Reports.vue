<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DateRangeFilter from "@/Components/DateRangeFilter.vue";
import { router } from "@inertiajs/vue3";

const currency = new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 });

export default {
  components: { Layout, PageHeader, DateRangeFilter },
  props: {
    revenuePerUser: { type: Array, default: () => [] },
    revenuePerShift: { type: Array, default: () => [] },
    revenuePerZone: { type: Array, default: () => [] },
    filters: { type: Object, default: () => ({ date_from: "", date_to: "" }) },
  },
  data() {
    return {
      activeTab: "user",
      isPrinting: false,
    };
  },
  computed: {
    userTotals() {
      return {
        total: this.revenuePerUser.reduce((s, u) => s + u.total_amount, 0),
        settlement: this.revenuePerUser.reduce((s, u) => s + u.total_settlement, 0),
        count: this.revenuePerUser.length,
      };
    },
    shiftTotals() {
      return {
        total: this.revenuePerShift.reduce((s, sh) => s + sh.total_amount, 0),
        cash: this.revenuePerShift.reduce((s, sh) => s + sh.cash_amount, 0),
        qris: this.revenuePerShift.reduce((s, sh) => s + sh.qris_amount, 0),
        count: this.revenuePerShift.length,
      };
    },
    zoneTotals() {
      return {
        total: this.revenuePerZone.reduce((s, z) => s + z.total_amount, 0),
        settlement: this.revenuePerZone.reduce((s, z) => s + z.total_settlement, 0),
        count: this.revenuePerZone.length,
      };
    },
  },
  methods: {
    money(value) {
      return currency.format(Number(value || 0));
    },
    onDateRangeChange(range) {
      router.get("/parkirgo/reports", { date_from: range.date_from, date_to: range.date_to }, { preserveState: true });
    },
    badge(status) {
      return { recorded: "info", verified: "success", rejected: "danger", approved: "success" }[status] || "secondary";
    },
    pct(num) {
      return Number(num || 0).toFixed(1);
    },
    printReport() {
      this.isPrinting = true;
      setTimeout(() => {
        window.print();
        this.isPrinting = false;
      }, 500);
    },
  },
};
</script>

<template>
  <Layout>
    <div class="print-area p-4">
      <div class="mb-4 no-print">
        <PageHeader title="Laporan Pendapatan" pageTitle="ParkirGo" class="mb-0" />
      </div>

      <div class="print-only text-center mb-5">
        <div class="d-flex justify-content-center mb-3">
           <img src="/images/logo_parkirgo.png?v=2" alt="ParkirGo" height="50" />
        </div>
        <h2 class="fw-bold mb-1">LAPORAN PENDAPATAN</h2>
        <div class="badge bg-light text-dark border p-2 px-3 mt-2">
           Periode: {{ filters.date_from }} s/d {{ filters.date_to }}
        </div>
      </div>

    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-end mb-4 no-print border-bottom">
      <ul class="nav nav-tabs nav-tabs-custom border-bottom-0 mb-0" role="tablist">
        <li class="nav-item" role="presentation">
          <button class="nav-link" :class="{ active: activeTab === 'user' }" @click="activeTab = 'user'" type="button">
            <i class="ri-user-line me-1"></i>Rekap Juru Parkir
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" :class="{ active: activeTab === 'shift' }" @click="activeTab = 'shift'" type="button">
            <i class="ri-calendar-line me-1"></i>Rekap Shift
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" :class="{ active: activeTab === 'zone' }" @click="activeTab = 'zone'" type="button">
            <i class="ri-map-pin-2-line me-1"></i>Rekap Zona
          </button>
        </li>
      </ul>
      <div class="pb-2 mt-3 mt-md-0 d-flex gap-2">
        <DateRangeFilter :date-from="filters.date_from" :date-to="filters.date_to" @change="onDateRangeChange" />
        <BButton variant="primary" size="sm" @click="printReport" class="flex-shrink-0">
          <i class="ri-printer-line me-1"></i>Cetak Laporan
        </BButton>
      </div>
    </div>

    <div v-show="activeTab === 'user' || isPrinting">
      <div class="print-only mb-3 mt-4 border-bottom pb-2">
        <h5 class="fw-bold mb-0 text-uppercase"><i class="ri-user-line me-2"></i>Rekap Pendapatan Per Pengguna</h5>
      </div>
      <BRow class="g-3 mb-4">
        <BCol md="4" class="col-print-4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Transaksi</p>
              <h3 class="mb-0">{{ money(userTotals.total) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="4" class="col-print-4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Setoran</p>
              <h3 class="mb-0">{{ money(userTotals.settlement) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="4" class="col-print-4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Jumlah Jukir</p>
              <h3 class="mb-0">{{ userTotals.count }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>

      <BCard no-body class="border-0 shadow-sm mb-5">
        <BCardBody>
          <div class="table-responsive table-card">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr class="text-center">
                  <th>#</th>
                  <th>Nama Jukir</th>
                  <th>Total Transaksi</th>
                  <th>Total Setoran</th>
                  <th>Jumlah Transaksi</th>
                  <th>Jenis Kendaraan</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, i) in revenuePerUser" :key="item.jukir_id">
                  <td class="text-muted">{{ i + 1 }}</td>
                  <td class="fw-semibold">{{ item.jukir_name }}</td>
                  <td class="text-end">{{ money(item.total_amount) }}</td>
                  <td class="text-end">{{ money(item.total_settlement) }}</td>
                  <td class="text-center">{{ item.transaction_count }}</td>
                  <td>
                    <div class="d-flex flex-wrap gap-2">
                      <div v-for="vt in item.vehicles" :key="vt.id" class="d-flex align-items-center bg-light px-2 py-1 rounded small">
                        <i :class="vt.icon" class="text-primary me-1"></i>
                        <span class="fw-semibold">{{ vt.count }}</span>
                      </div>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </BCardBody>
      </BCard>
    </div>

    <div v-show="activeTab === 'shift' || isPrinting">
      <div class="print-only mb-3 mt-5 border-bottom pb-2" style="page-break-before: always;">
        <h5 class="fw-bold mb-0 text-uppercase"><i class="ri-calendar-line me-2"></i>Rekap Pendapatan Per Shift</h5>
      </div>
      <BRow class="g-3 mb-4">
        <BCol md="3" class="col-print-3">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Setoran</p>
              <h3 class="mb-0">{{ money(shiftTotals.total) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="3" class="col-print-3">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Cash</p>
              <h3 class="mb-0">{{ money(shiftTotals.cash) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="3" class="col-print-3">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">QRIS</p>
              <h3 class="mb-0">{{ money(shiftTotals.qris) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="3" class="col-print-3">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Jumlah Shift</p>
              <h3 class="mb-0">{{ shiftTotals.count }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>

      <BCard no-body class="border-0 shadow-sm mb-5">
        <BCardBody>
          <div class="table-responsive table-card">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr class="text-center">
                  <th>No. Setoran</th>
                  <th>Jukir</th>
                  <th>Zona</th>
                  <th>Cash</th>
                  <th>QRIS</th>
                  <th>Total</th>
                  <th>Jenis Kendaraan</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in revenuePerShift" :key="item.id">
                  <td class="fw-semibold">{{ item.settlement_number }}</td>
                  <td>{{ item.jukir_name }}</td>
                  <td>{{ item.zone_name }}</td>
                  <td class="text-end">{{ money(item.cash_amount) }}</td>
                  <td class="text-end">{{ money(item.qris_amount) }}</td>
                  <td class="text-end fw-semibold">{{ money(item.total_amount) }}</td>
                  <td>
                    <div class="d-flex flex-wrap gap-2">
                      <div v-for="vt in item.vehicles" :key="vt.id" class="d-flex align-items-center bg-light px-2 py-1 rounded small">
                        <i :class="vt.icon" class="text-primary me-1"></i>
                        <span class="fw-semibold">{{ vt.count }}</span>
                      </div>
                    </div>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="`bg-${badge(item.status)}-subtle text-${badge(item.status)}`">{{ item.status }}</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </BCardBody>
      </BCard>
    </div>

    <div v-show="activeTab === 'zone' || isPrinting">
      <div class="print-only mb-3 mt-5 border-bottom pb-2" style="page-break-before: always;">
        <h5 class="fw-bold mb-0 text-uppercase"><i class="ri-map-pin-2-line me-2"></i>Rekap Pendapatan Per Zona</h5>
      </div>
      <BRow class="g-3 mb-4">
        <BCol md="4" class="col-print-4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Transaksi</p>
              <h3 class="mb-0">{{ money(zoneTotals.total) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="4" class="col-print-4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Setoran</p>
              <h3 class="mb-0">{{ money(zoneTotals.settlement) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="4" class="col-print-4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Jumlah Zona</p>
              <h3 class="mb-0">{{ zoneTotals.count }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>

      <BCard no-body class="border-0 shadow-sm mb-5">
        <BCardBody>
          <div class="table-responsive table-card">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr class="text-center">
                  <th>#</th>
                  <th>Zona</th>
                  <th>Kota</th>
                  <th>Total Transaksi</th>
                  <th>Total Setoran</th>
                  <th>Jumlah Transaksi</th>
                  <th>Jenis Kendaraan</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, i) in revenuePerZone" :key="item.zone_id">
                  <td class="text-muted">{{ i + 1 }}</td>
                  <td class="fw-semibold">{{ item.zone_name }}</td>
                  <td>{{ item.city || "-" }}</td>
                  <td class="text-end">{{ money(item.total_amount) }}</td>
                  <td class="text-end">{{ money(item.total_settlement) }}</td>
                  <td class="text-center">{{ item.transaction_count }}</td>
                  <td>
                    <div class="d-flex flex-wrap gap-2">
                      <div v-for="vt in item.vehicles" :key="vt.id" class="d-flex align-items-center bg-light px-2 py-1 rounded small">
                        <i :class="vt.icon" class="text-primary me-1"></i>
                        <span class="fw-semibold">{{ vt.count }}</span>
                      </div>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </BCardBody>
      </BCard>
    </div>
    </div>
  </Layout>
</template>

<style scoped>
@media print {
  .no-print, .nav-tabs, .btn, .card-header, .page-title-box, .app-menu, .navbar-header, footer, .footer {
    display: none !important;
  }
  .main-content { margin-left: 0 !important; padding: 0 !important; margin-top: 0 !important; }
  .page-content { padding: 0 !important; }
  .card { border: 1px solid #ddd !important; box-shadow: none !important; margin-bottom: 20px !important; page-break-inside: avoid; }
  .card-body { padding: 15px !important; }
  .print-only { display: block !important; }
  .print-area { width: 100%; padding: 0; }
  .col-print-4 { width: 33.333% !important; float: left; padding: 5px; }
  .col-print-3 { width: 25% !important; float: left; padding: 5px; }
  .row { display: flex !important; flex-wrap: wrap !important; }
  .table-responsive { overflow: visible !important; }
  table { width: 100% !important; border-collapse: collapse !important; }
  th, td { border: 1px solid #ddd !important; padding: 8px !important; font-size: 11px !important; }
  th { background-color: #f8f9fa !important; -webkit-print-color-adjust: exact; }
  .badge { border: 1px solid #ccc !important; color: #333 !important; background: transparent !important; }
  h3, h4, h5 { color: #000 !important; }
  hr { border-top: 2px solid #000 !important; margin: 20px 0 !important; }
}
.print-only { display: none; }
</style>
