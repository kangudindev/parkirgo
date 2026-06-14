<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import DateRangeFilter from "@/Components/DateRangeFilter.vue";
import { router } from "@inertiajs/vue3";

const currency = new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 });

export default {
  components: { Layout, PageHeader, DataTable, DateRangeFilter },
  props: {
    sessions: { type: Object, default: () => ({ data: [] }) },
    attendances: { type: Array, default: () => [] },
    zones: { type: Array, default: () => [] },
    vehicleTypes: { type: Array, default: () => [] },
    filters: { type: Object, default: () => ({}) },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
  },
  data() {
    return {
      searchQuery: "",
      perPageVal: 15,
      tableSortField: this.sortField,
      tableSortDir: this.sortDir,
      showDetailModal: false,
      detailSession: null,
      filterForm: {
        zone_id: this.filters.zone_id || "",
        vehicle_type_id: this.filters.vehicle_type_id || "",
        date_from: this.filters.date_from || new Date().toISOString().split('T')[0],
        date_to: this.filters.date_to || new Date().toISOString().split('T')[0],
      }
    };
  },
  computed: {
    columns() {
      return [
        { key: "ticket_number", label: "Tiket" },
        { key: "plate_number", label: "Plat" },
        { key: "vehicle_name", label: "Kendaraan", width: "100px" },
        { key: "zone_name", label: "Zona" },
        { key: "jukir_name", label: "Jukir" },
        { key: "entry_at", label: "Masuk" },
        { key: "exit_at", label: "Keluar" },
        { key: "duration_minutes", label: "Durasi", width: "80px" },
        { key: "amount", label: "Biaya", width: "130px" },
        { key: "denda", label: "Denda", width: "100px" },
        { key: "status", label: "Status", width: "100px" },
        { key: "payment_status", label: "Bayar", width: "90px" },
        { key: "actions", label: "", sortable: false, width: "50px" },
      ];
    },
  },
  methods: {
    money(v) { return currency.format(Number(v || 0)); },
    badge(status) {
      return { active: "success", exited: "secondary", completed: "primary", synced: "success", pending: "warning" }[status] || "info";
    },
    date(value) {
      return value ? new Date(value).toLocaleString("id-ID") : "-";
    },
    durasi(min) {
      if (!min && min !== 0) return "-";
      const h = Math.floor(min / 60);
      const m = min % 60;
      return h > 0 ? `${h}j ${m}m` : `${m}m`;
    },
    openDetail(s) {
      this.detailSession = s;
      this.showDetailModal = true;
    },
    onDateRangeChange(range) {
      this.filterForm.date_from = range.date_from;
      this.filterForm.date_to = range.date_to;
      this.applyFilters();
    },
    applyFilters() {
      router.get("/parkirgo/operations", { 
        ...this.filterForm,
        search: this.searchQuery, 
        sort_field: this.tableSortField, 
        sort_dir: this.tableSortDir, 
        per_page: this.perPageVal 
      }, { preserveState: true });
    },
    onSort(field, dir) {
      this.tableSortField = field; this.tableSortDir = dir;
      this.applyFilters();
    },
    onSearch(q) {
      this.searchQuery = q;
      this.applyFilters();
    },
    onPage(page) {
      router.get("/parkirgo/operations", { 
        page, 
        ...this.filterForm,
        search: this.searchQuery, 
        sort_field: this.tableSortField, 
        sort_dir: this.tableSortDir, 
        per_page: this.perPageVal 
      }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      this.applyFilters();
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Sesi Parkir" pageTitle="ParkirGo" />

    <BCard no-body class="border-0 shadow-sm mb-4">
      <BCardBody>
        <BRow class="g-3">
          <BCol md="3">
            <label class="form-label text-muted small mb-1">Pilih Zona</label>
            <select v-model="filterForm.zone_id" class="form-select form-select-sm" @change="applyFilters">
              <option value="">Semua Zona</option>
              <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.name }}</option>
            </select>
          </BCol>
          <BCol md="3">
            <label class="form-label text-muted small mb-1">Jenis Kendaraan</label>
            <select v-model="filterForm.vehicle_type_id" class="form-select form-select-sm" @change="applyFilters">
              <option value="">Semua Jenis</option>
              <option v-for="vt in vehicleTypes" :key="vt.id" :value="vt.id">{{ vt.name }}</option>
            </select>
          </BCol>
          <BCol md="6">
            <label class="form-label text-muted small mb-1">Filter Tanggal</label>
            <DateRangeFilter 
              :date-from="filterForm.date_from" 
              :date-to="filterForm.date_to" 
              @change="onDateRangeChange" 
            />
          </BCol>
        </BRow>
      </BCardBody>
    </BCard>

    <BRow>
      <BCol xl="12">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader class="d-flex align-items-center">
            <i class="ri-parking-box-line me-2 fs-18 text-primary"></i>
            <BCardTitle class="mb-0 flex-grow-1">Sesi Parkir</BCardTitle>
            <span class="badge bg-success-subtle text-success">Flat bayar masuk · Progresif bayar keluar</span>
          </BCardHeader>
          <BCardBody>
            <DataTable :columns="columns" :data="sessions" :sort-field="tableSortField" :sort-dir="tableSortDir"
              @sort="onSort" @search="onSearch" @page-change="onPage" @per-page-change="onPerPage">
              <template #cell-vehicle_name="{ row }">{{ row.vehicleTypeMaster?.name || row.vehicle_type || "-" }}</template>
              <template #cell-zone_name="{ row }">{{ row.zone?.name }}</template>
              <template #cell-jukir_name="{ row }">{{ row.jukir?.name }}</template>
              <template #cell-entry_at="{ row }">{{ date(row.entry_at) }}</template>
              <template #cell-exit_at="{ row }">{{ date(row.exit_at) }}</template>
              <template #cell-duration_minutes="{ row }">{{ durasi(row.duration_minutes) }}</template>
              <template #cell-amount="{ row }">{{ money(row.final_amount ?? row.estimated_amount) }}</template>
              <template #cell-denda="{ row }">
                <span v-if="row.penalty_fee" class="text-danger fw-semibold">{{ money(row.penalty_fee) }}</span>
                <span v-else class="text-muted">-</span>
              </template>
              <template #cell-status="{ row }">
                <span class="badge" :class="`bg-${badge(row.status)}-subtle text-${badge(row.status)}`">{{ row.status }}</span>
              </template>
              <template #cell-payment_status="{ row }">
                <span class="badge" :class="row.payment_status === 'paid' ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning'">{{ row.payment_status }}</span>
              </template>
              <template #cell-actions="{ row }">
                <BButton size="sm" variant="soft-primary" @click="openDetail(row)" title="Detail">
                  <i class="ri-eye-line"></i>
                </BButton>
              </template>
            </DataTable>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BModal v-model="showDetailModal" title="Detail Sesi Parkir" hide-footer centered size="lg">
      <div v-if="detailSession" class="row g-3">
        <div class="col-md-6">
          <table class="table table-sm table-borderless mb-0">
            <tr><td class="text-muted" style="width:120px">No. Tiket</td><td class="fw-semibold">{{ detailSession.ticket_number }}</td></tr>
            <tr><td class="text-muted">Plat Nomor</td><td class="fw-semibold">{{ detailSession.plate_number }}</td></tr>
            <tr><td class="text-muted">Kendaraan</td><td>{{ detailSession.vehicleTypeMaster?.name || detailSession.vehicle_type }}</td></tr>
            <tr><td class="text-muted">Zona</td><td>{{ detailSession.zone?.name }} ({{ detailSession.zone?.code }})</td></tr>
            <tr><td class="text-muted">Jukir</td><td>{{ detailSession.jukir?.name }}</td></tr>
            <tr><td class="text-muted">Tarif</td><td>{{ detailSession.tariff ? (detailSession.tariff.pricing_type === 'flat' ? 'Flat' : 'Progresif') + ' - ' + detailSession.tariff.vehicleTypeMaster?.name : '-' }}</td></tr>
          </table>
        </div>
        <div class="col-md-6">
          <table class="table table-sm table-borderless mb-0">
            <tr><td class="text-muted" style="width:120px">Masuk</td><td>{{ date(detailSession.entry_at) }}</td></tr>
            <tr><td class="text-muted">Keluar</td><td>{{ date(detailSession.exit_at) }}</td></tr>
            <tr><td class="text-muted">Durasi</td><td>{{ durasi(detailSession.duration_minutes) }}</td></tr>
            <tr><td class="text-muted">Biaya</td><td class="fw-semibold">{{ money(detailSession.final_amount ?? detailSession.estimated_amount) }}</td></tr>
            <tr v-if="detailSession.penalty_fee"><td class="text-muted">Denda</td><td class="text-danger fw-semibold">{{ money(detailSession.penalty_fee) }}</td></tr>
            <tr><td class="text-muted">Status</td><td><span class="badge" :class="`bg-${badge(detailSession.status)}-subtle text-${badge(detailSession.status)}`">{{ detailSession.status }}</span></td></tr>
            <tr><td class="text-muted">Pembayaran</td><td><span class="badge" :class="detailSession.payment_status === 'paid' ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning'">{{ detailSession.payment_status }}</span></td></tr>
          </table>
        </div>
        <div v-if="detailSession.is_card_lost" class="col-12">
          <BAlert variant="warning" show class="mb-0 py-2 small">
            <i class="ri-alert-line me-1"></i> Karcis hilang — {{ detailSession.owner_name || 'Nama tidak tercatat' }}
          </BAlert>
        </div>
        <div v-if="detailSession.jukir_note" class="col-12">
          <label class="text-muted small">Catatan Jukir:</label>
          <p class="mb-0">{{ detailSession.jukir_note }}</p>
        </div>
        <div class="col-12">
          <BRow class="g-2">
            <BCol v-if="detailSession.entry_photo_path" md="6">
              <small class="text-muted">Foto Masuk</small>
              <img :src="'/storage/' + detailSession.entry_photo_path" class="img-fluid rounded border" alt="entry" />
            </BCol>
            <BCol v-if="detailSession.exit_photo_path" md="6">
              <small class="text-muted">Foto Keluar</small>
              <img :src="'/storage/' + detailSession.exit_photo_path" class="img-fluid rounded border" alt="exit" />
            </BCol>
          </BRow>
        </div>
      </div>
      <div class="d-flex justify-content-end mt-3">
        <BButton variant="light" @click="showDetailModal=false">Tutup</BButton>
      </div>
    </BModal>
  </Layout>
</template>
