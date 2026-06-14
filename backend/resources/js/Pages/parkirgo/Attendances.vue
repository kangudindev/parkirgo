<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import DateRangeFilter from "@/Components/DateRangeFilter.vue";
import { router } from "@inertiajs/vue3";

export default {
  components: { Layout, PageHeader, DataTable, DateRangeFilter },
  props: {
    attendances: { type: Object, default: () => ({ data: [] }) },
    zones: { type: Array, default: () => [] },
    filters: { type: Object, default: () => ({ date_from: "", date_to: "" }) },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
  },
  data() {
    return {
      showSelfieModal: false,
      selfieUrl: null,
      tableSortField: this.sortField,
      tableSortDir: this.sortDir,
      searchQuery: "",
      perPageVal: 15,
    };
  },
  computed: {
    columns() {
      return [
        { key: "user_name", label: "Jukir" },
        { key: "user_nik", label: "NIK" },
        { key: "zone_name", label: "Zona" },
        { key: "shift_code", label: "Shift" },
        { key: "check_in_at", label: "Check-In" },
        { key: "check_out_at", label: "Check-Out" },
        { key: "location", label: "Koordinat", sortable: false },
        { key: "selfie", label: "Selfie", sortable: false, width: "80px" },
        { key: "sync_status", label: "Sync", width: "100px" },
      ];
    },
  },
  methods: {
    date(value) {
      if (!value) return "-";
      return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
    },
    coord(lat, lng) {
      if (!lat || !lng) return "-";
      return `${Number(lat).toFixed(6)}, ${Number(lng).toFixed(6)}`;
    },
    mapsLink(lat, lng) {
      if (!lat || !lng) return "#";
      return `https://www.google.com/maps?q=${lat},${lng}`;
    },
    openSelfie(path) {
      if (!path) return;
      this.selfieUrl = "/storage/" + path;
      this.showSelfieModal = true;
    },
    onDateRangeChange(range) {
      router.get("/parkirgo/attendances", { date_from: range.date_from, date_to: range.date_to, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSort(field, dir) {
      this.tableSortField = field; this.tableSortDir = dir;
      router.get("/parkirgo/attendances", { sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal, date_from: this.filters.date_from, date_to: this.filters.date_to }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get("/parkirgo/attendances", { search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal, date_from: this.filters.date_from, date_to: this.filters.date_to }, { preserveState: true });
    },
    onPage(page) {
      router.get("/parkirgo/attendances", { page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal, date_from: this.filters.date_from, date_to: this.filters.date_to }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get("/parkirgo/attendances", { per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, date_from: this.filters.date_from, date_to: this.filters.date_to }, { preserveState: true });
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Absensi Juru Parkir" pageTitle="ParkirGo" />

    <BCard no-body class="border-0 shadow-sm mb-4">
      <BCardBody>
        <DateRangeFilter :date-from="filters.date_from" :date-to="filters.date_to" @change="onDateRangeChange" />
      </BCardBody>
    </BCard>

    <BCard no-body class="border-0 shadow-sm">
      <BCardHeader>
        <BCardTitle class="mb-1">Riwayat Absensi</BCardTitle>
        <p class="text-muted mb-0">Data absensi masuk/pulang juru parkir.</p>
      </BCardHeader>
      <BCardBody>
        <DataTable :columns="columns" :data="attendances" :sort-field="tableSortField" :sort-dir="tableSortDir"
          @sort="onSort" @search="onSearch" @page-change="onPage" @per-page-change="onPerPage">
          <template #cell-user_name="{ row }">{{ row.user?.name || "-" }}</template>
          <template #cell-user_nik="{ row }">{{ row.user?.nik || "-" }}</template>
          <template #cell-zone_name="{ row }">{{ row.zone?.name || "-" }}</template>
          <template #cell-shift_code="{ row }">{{ row.shift?.code || "-" }}</template>
          <template #cell-check_in_at="{ row }">{{ date(row.check_in_at) }}</template>
          <template #cell-check_out_at="{ row }">{{ date(row.check_out_at) }}</template>
          <template #cell-location="{ row }">
            <span v-if="row.check_in_latitude || row.check_out_latitude">
              <a :href="mapsLink(row.check_in_latitude || row.check_out_latitude, row.check_in_longitude || row.check_out_longitude)" target="_blank" class="text-primary text-decoration-underline small">
                {{ coord(row.check_in_latitude, row.check_in_longitude) || coord(row.check_out_latitude, row.check_out_longitude) }}
              </a>
            </span>
            <span v-else class="text-muted">-</span>
          </template>
          <template #cell-selfie="{ row }">
            <BButton v-if="row.selfie_path" size="sm" variant="soft-info" @click="openSelfie(row.selfie_path)">
              <i class="ri-camera-2-line"></i>
            </BButton>
            <span v-else class="text-muted">-</span>
          </template>
          <template #cell-sync_status="{ row }">
            <span class="badge" :class="row.sync_status === 'synced' ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning'">{{ row.sync_status }}</span>
          </template>
        </DataTable>
      </BCardBody>
    </BCard>

    <BModal v-model="showSelfieModal" title="Foto Selfie" hide-footer centered size="sm">
      <div class="text-center">
        <img :src="selfieUrl" class="img-fluid rounded" alt="Selfie" />
      </div>
      <div class="d-flex justify-content-center mt-3">
        <BButton variant="light" @click="showSelfieModal=false">Tutup</BButton>
      </div>
    </BModal>
  </Layout>
</template>
