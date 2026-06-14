<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import { router } from "@inertiajs/vue3";

export default {
  components: { Layout, PageHeader, DataTable },
  props: {
    sessions: { type: Object, default: () => ({ data: [] }) },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
  },
  data() {
    return {
      searchQuery: "",
      perPageVal: 15,
      tableSortField: this.sortField,
      tableSortDir: this.sortDir,
    };
  },
  computed: {
    columns() {
      return [
        { key: "ticket_number", label: "Tiket" },
        { key: "plate_number", label: "Plat" },
        { key: "zone_name", label: "Zona" },
        { key: "jukir_name", label: "Jukir" },
        { key: "entry_at", label: "Masuk" },
        { key: "status", label: "Status", width: "100px" },
        { key: "payment_status", label: "Bayar", width: "100px" },
      ];
    },
  },
  methods: {
    badge(status) {
      return { active: "success", exited: "secondary", synced: "success", pending: "warning" }[status] || "info";
    },
    date(value) {
      return value ? new Date(value).toLocaleString("id-ID") : "-";
    },
    onSort(field, dir) {
      this.tableSortField = field; this.tableSortDir = dir;
      router.get("/parkirgo/operations", { sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get("/parkirgo/operations", { search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal }, { preserveState: true });
    },
    onPage(page) {
      router.get("/parkirgo/operations", { page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get("/parkirgo/operations", { per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery }, { preserveState: true });
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Operasional Lapangan" pageTitle="ParkirGo" />

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
              <template #cell-zone_name="{ row }">{{ row.zone?.name }}</template>
              <template #cell-jukir_name="{ row }">{{ row.jukir?.name }}</template>
              <template #cell-entry_at="{ row }">{{ date(row.entry_at) }}</template>
              <template #cell-status="{ row }">
                <span class="badge" :class="`bg-${badge(row.status)}-subtle text-${badge(row.status)}`">{{ row.status }}</span>
              </template>
              <template #cell-payment_status="{ row }">
                <span class="badge" :class="row.payment_status === 'paid' ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning'">{{ row.payment_status }}</span>
              </template>
            </DataTable>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>
  </Layout>
</template>
