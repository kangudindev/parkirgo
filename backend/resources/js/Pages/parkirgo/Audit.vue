<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import { router } from "@inertiajs/vue3";

export default {
  components: { Layout, PageHeader, DataTable },
  props: {
    logs: { type: Object, default: () => ({ data: [] }) },
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
        { key: "created_at", label: "Waktu" },
        { key: "user_name", label: "Pengguna" },
        { key: "action", label: "Aksi" },
        { key: "entity_type", label: "Entitas" },
        { key: "entity_id", label: "ID Entitas" },
        { key: "ip_address", label: "IP Address" },
      ];
    },
  },
  methods: {
    formatDate(value) {
      if (!value) return "-";
      return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
    },
    actionClass(action) {
      const a = (action || "").toLowerCase();
      if (a.includes("create") || a.includes("buat")) return "success";
      if (a.includes("update") || a.includes("ubah")) return "warning";
      if (a.includes("delete") || a.includes("hapus")) return "danger";
      if (a.includes("login")) return "primary";
      return "secondary";
    },
    onSort(field, dir) {
      this.tableSortField = field;
      this.tableSortDir = dir;
      router.get("/parkirgo/audit", { sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get("/parkirgo/audit", { search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal }, { preserveState: true });
    },
    onPage(page) {
      router.get("/parkirgo/audit", { page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get("/parkirgo/audit", { per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery }, { preserveState: true });
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Audit Log" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total Aktivitas</p>
                <h3 class="mb-0">{{ logs.total || logs.data?.length || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-history-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BCard no-body class="border-0 shadow-sm">
      <BCardHeader>
        <BCardTitle class="mb-1">Riwayat Aktivitas Sistem</BCardTitle>
        <p class="text-muted mb-0">Pantau perubahan data dan aktivitas penting pada ParkirGo.</p>
      </BCardHeader>
      <BCardBody>
        <DataTable
          :columns="columns"
          :data="logs"
          :sort-field="tableSortField"
          :sort-dir="tableSortDir"
          @sort="onSort"
          @search="onSearch"
          @page-change="onPage"
          @per-page-change="onPerPage"
        >
          <template #cell-created_at="{ row }">{{ formatDate(row.created_at) }}</template>
          <template #cell-user_name="{ row }">
            <div class="fw-semibold">{{ row.user?.name || "Sistem" }}</div>
            <small class="text-muted">{{ row.user?.email || "-" }}</small>
          </template>
          <template #cell-action="{ row }">
            <span :class="`badge bg-${actionClass(row.action)}-subtle text-${actionClass(row.action)}`">{{ row.action }}</span>
          </template>
          <template #cell-entity_id="{ row }">{{ row.entity_id || "-" }}</template>
        </DataTable>
      </BCardBody>
    </BCard>
  </Layout>
</template>

<style scoped>
.stat-card { transition: transform .2s ease, box-shadow .2s ease; }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 18px 45px rgba(15, 23, 42, .12) !important; }
.avatar-sm { width: 48px; height: 48px; }
</style>
