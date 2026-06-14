<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
const currency = new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 });

export default {
  components: { Layout, PageHeader },
  props: {
    transactions: { type: Array, default: () => [] },
    settlements: { type: Array, default: () => [] },
  },
  computed: {
    totals() {
      return this.transactions.reduce((acc, trx) => {
        acc[trx.payment_method] = (acc[trx.payment_method] || 0) + Number(trx.amount || 0);
        acc.all += Number(trx.amount || 0);
        return acc;
      }, { all: 0, cash: 0, qris: 0 });
    },
  },
  methods: {
    money(value) {
      return currency.format(Number(value || 0));
    },
    badge(status) {
      return { recorded: "info", verified: "success", rejected: "danger", approved: "success" }[status] || "secondary";
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Finance & Rekonsiliasi" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm metric-card qris">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total QRIS</p>
                <h3 class="mb-0">{{ money(totals.qris) }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-success-subtle text-success d-flex align-items-center justify-content-center">
                <i class="ri-qr-code-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm metric-card cash">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total Cash</p>
                <h3 class="mb-0">{{ money(totals.cash) }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-warning-subtle text-warning d-flex align-items-center justify-content-center">
                <i class="ri-cash-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm metric-card total">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total Tercatat</p>
                <h3 class="mb-0">{{ money(totals.all) }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-bank-card-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BRow>
      <BCol xl="7">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader>
            <BCardTitle class="mb-0">Transaksi QRIS/Cash</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div class="table-responsive table-card">
              <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th>No Transaksi</th>
                    <th>Zona</th>
                    <th>Metode</th>
                    <th>Amount</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="trx in transactions" :key="trx.id">
                    <td class="fw-semibold">{{ trx.transaction_number }}</td>
                    <td>{{ trx.zone?.name }}</td>
                    <td class="text-uppercase">{{ trx.payment_method }}</td>
                    <td>{{ money(trx.amount) }}</td>
                    <td><span class="badge" :class="`bg-${badge(trx.status)}-subtle text-${badge(trx.status)}`">{{ trx.status }}</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="5">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader>
            <BCardTitle class="mb-0">Setoran Shift</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div v-for="settlement in settlements" :key="settlement.id" class="p-3 rounded border mb-3">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <h6 class="mb-1">{{ settlement.settlement_number }}</h6>
                  <p class="text-muted mb-1">{{ settlement.jukir?.name }} · {{ settlement.zone?.name }}</p>
                  <small>Cash {{ money(settlement.cash_amount) }} · QRIS {{ money(settlement.qris_amount) }}</small>
                </div>
                <span class="badge" :class="`bg-${badge(settlement.status)}-subtle text-${badge(settlement.status)}`">{{ settlement.status }}</span>
              </div>
              <div class="progress mt-3" style="height: 6px">
                <div class="progress-bar bg-success" :style="{ width: `${settlement.total_amount ? (settlement.qris_amount / settlement.total_amount) * 100 : 0}%` }"></div>
              </div>

            </div>
            <div v-if="!settlements.length" class="text-center text-muted py-3">Belum ada setoran.</div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>
  </Layout>
</template>

<style scoped>
.metric-card { position: relative; overflow: hidden; }
.metric-card::after { content: ""; position: absolute; right: -40px; top: -40px; width: 120px; height: 120px; border-radius: 50%; opacity: .14; }
.metric-card.qris::after { background: #0ab39c; }
.metric-card.cash::after { background: #f7b84b; }
.metric-card.total::after { background: #405189; }
</style>
