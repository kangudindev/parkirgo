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
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Laporan Pendapatan" pageTitle="ParkirGo" />

    <BCard no-body class="border-0 shadow-sm mb-4">
      <BCardBody>
        <DateRangeFilter :date-from="filters.date_from" :date-to="filters.date_to" @change="onDateRangeChange" />
      </BCardBody>
    </BCard>

    <ul class="nav nav-tabs nav-tabs-custom mb-4" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link" :class="{ active: activeTab === 'user' }" @click="activeTab = 'user'" type="button">
          <i class="ri-user-line me-1"></i>Per Pengguna
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" :class="{ active: activeTab === 'shift' }" @click="activeTab = 'shift'" type="button">
          <i class="ri-calendar-line me-1"></i>Per Shift
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" :class="{ active: activeTab === 'zone' }" @click="activeTab = 'zone'" type="button">
          <i class="ri-map-pin-2-line me-1"></i>Per Zona
        </button>
      </li>
    </ul>

    <div v-show="activeTab === 'user'">
      <BRow class="g-3 mb-4">
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Transaksi</p>
              <h3 class="mb-0">{{ money(userTotals.total) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Setoran</p>
              <h3 class="mb-0">{{ money(userTotals.settlement) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Jumlah Jukir</p>
              <h3 class="mb-0">{{ userTotals.count }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>

      <BCard no-body class="border-0 shadow-sm">
        <BCardBody>
          <div class="table-responsive table-card">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>#</th>
                  <th>Nama Jukir</th>
                  <th class="text-end">Total Transaksi</th>
                  <th class="text-end">Total Setoran</th>
                  <th class="text-center">Jumlah Transaksi</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, i) in revenuePerUser" :key="item.jukir_id">
                  <td class="text-muted">{{ i + 1 }}</td>
                  <td class="fw-semibold">{{ item.jukir_name }}</td>
                  <td class="text-end">{{ money(item.total_amount) }}</td>
                  <td class="text-end">{{ money(item.total_settlement) }}</td>
                  <td class="text-center">{{ item.transaction_count }}</td>
                </tr>
                <tr v-if="!revenuePerUser.length">
                  <td colspan="5" class="text-center text-muted py-4">Belum ada data transaksi pada periode ini.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </BCardBody>
      </BCard>
    </div>

    <div v-show="activeTab === 'shift'">
      <BRow class="g-3 mb-4">
        <BCol md="3">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Setoran</p>
              <h3 class="mb-0">{{ money(shiftTotals.total) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="3">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Cash</p>
              <h3 class="mb-0">{{ money(shiftTotals.cash) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="3">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">QRIS</p>
              <h3 class="mb-0">{{ money(shiftTotals.qris) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="3">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Jumlah Shift</p>
              <h3 class="mb-0">{{ shiftTotals.count }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>

      <BCard no-body class="border-0 shadow-sm">
        <BCardBody>
          <div class="table-responsive table-card">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>No. Setoran</th>
                  <th>Kode Shift</th>
                  <th>Tanggal</th>
                  <th>Jukir</th>
                  <th>Zona</th>
                  <th class="text-end">Cash</th>
                  <th class="text-end">QRIS</th>
                  <th class="text-end">Total</th>
                  <th class="text-center">Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in revenuePerShift" :key="item.id">
                  <td class="fw-semibold">{{ item.settlement_number }}</td>
                  <td>{{ item.shift_code || "-" }}</td>
                  <td>{{ item.shift_date || "-" }}</td>
                  <td>{{ item.jukir_name }}</td>
                  <td>{{ item.zone_name }}</td>
                  <td class="text-end">{{ money(item.cash_amount) }}</td>
                  <td class="text-end">{{ money(item.qris_amount) }}</td>
                  <td class="text-end fw-semibold">{{ money(item.total_amount) }}</td>
                  <td class="text-center">
                    <span class="badge" :class="`bg-${badge(item.status)}-subtle text-${badge(item.status)}`">{{ item.status }}</span>
                  </td>
                </tr>
                <tr v-if="!revenuePerShift.length">
                  <td colspan="9" class="text-center text-muted py-4">Belum ada setoran pada periode ini.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </BCardBody>
      </BCard>
    </div>

    <div v-show="activeTab === 'zone'">
      <BRow class="g-3 mb-4">
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Transaksi</p>
              <h3 class="mb-0">{{ money(zoneTotals.total) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Total Setoran</p>
              <h3 class="mb-0">{{ money(zoneTotals.settlement) }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm">
            <BCardBody>
              <p class="text-muted mb-1">Jumlah Zona</p>
              <h3 class="mb-0">{{ zoneTotals.count }}</h3>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>

      <BCard no-body class="border-0 shadow-sm">
        <BCardBody>
          <div class="table-responsive table-card">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>#</th>
                  <th>Zona</th>
                  <th>Kode</th>
                  <th>Kota</th>
                  <th class="text-end">Total Transaksi</th>
                  <th class="text-end">Total Setoran</th>
                  <th class="text-center">Jumlah Transaksi</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, i) in revenuePerZone" :key="item.zone_id">
                  <td class="text-muted">{{ i + 1 }}</td>
                  <td class="fw-semibold">{{ item.zone_name }}</td>
                  <td>{{ item.zone_code }}</td>
                  <td>{{ item.city || "-" }}</td>
                  <td class="text-end">{{ money(item.total_amount) }}</td>
                  <td class="text-end">{{ money(item.total_settlement) }}</td>
                  <td class="text-center">{{ item.transaction_count }}</td>
                </tr>
                <tr v-if="!revenuePerZone.length">
                  <td colspan="7" class="text-center text-muted py-4">Belum ada data transaksi pada periode ini.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </BCardBody>
      </BCard>
    </div>
  </Layout>
</template>
