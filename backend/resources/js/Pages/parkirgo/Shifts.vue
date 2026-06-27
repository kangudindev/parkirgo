<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import { router } from "@inertiajs/vue3";
import Swal from "sweetalert2";

export default {
  components: { Layout, PageHeader, DataTable },
  props: {
    shifts: { type: Object, default: () => ({ data: [] }) },
    zones: { type: Array, default: () => [] },
    users: { type: Array, default: () => [] },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
  },
  data() {
    return {
      showModal: false,
      editing: null,
      form: { zone_id: null, user_id: null, shift_date: "", start_time: "", end_time: "", status: "active" },
      searchQuery: "",
      perPageVal: 15,
      tableSortField: this.sortField,
      tableSortDir: this.sortDir,
    };
  },
  computed: {
    columns() {
      return [
        { key: "code", label: "Kode", width: "140px" },
        { key: "user_name", label: "Jukir" },
        { key: "zone_name", label: "Zona" },
        { key: "shift_date", label: "Tanggal" },
        { key: "time", label: "Jam" },
        { key: "status", label: "Status", width: "100px" },
        { key: "actions", label: "Aksi", sortable: false, width: "100px" },
      ];
    },
  },
  methods: {
    open(s) {
      this.editing = s;
      if (s) this.form = { zone_id: s.zone_id, user_id: s.user_id, shift_date: s.shift_date?.substring(0,10) || "", start_time: s.start_time?.substring(0,5) || "", end_time: s.end_time?.substring(0,5) || "", status: s.status };
      else this.form = { zone_id: null, user_id: null, shift_date: "", start_time: "", end_time: "", status: "active" };
      this.showModal = true;
    },
    save() {
      if (!this.form.zone_id || !this.form.user_id || !this.form.shift_date || !this.form.start_time || !this.form.end_time) {
        this.$page.props.flash = { error: "Semua field harus diisi." };
        return;
      }
      if (this.form.start_time >= this.form.end_time) {
        this.$page.props.flash = { error: "Jam selesai harus setelah jam mulai." };
        return;
      }
      if (this.editing) router.post(route("parkirgo.shifts.update", this.editing.id), this.form, { preserveScroll: true, onSuccess: () => this.showModal = false });
      else router.post(route("parkirgo.shifts.store"), this.form, { preserveScroll: true, onSuccess: () => this.showModal = false });
    },
    remove(s) {
      Swal.fire({
        title: "Hapus Shift?",
        text: "Shift yang dihapus tidak bisa dikembalikan.",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#f06548",
        confirmButtonText: "Ya, Hapus",
        cancelButtonText: "Batal",
      }).then((r) => { if (r.isConfirmed) router.delete(route("parkirgo.shifts.destroy", s.id), { preserveScroll: true }); });
    },
    onSort(field, dir) {
      this.tableSortField = field;
      this.tableSortDir = dir;
      router.get("/parkirgo/shifts", { sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get("/parkirgo/shifts", { search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal }, { preserveState: true });
    },
    onPage(page) {
      router.get("/parkirgo/shifts", { page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get("/parkirgo/shifts", { per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery }, { preserveState: true });
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Manajemen Shift" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total Shift</p>
                <h3 class="mb-0">{{ shifts.total || shifts.data?.length || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-info-subtle text-info d-flex align-items-center justify-content-center">
                <i class="ri-calendar-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BCard no-body class="border-0 shadow-sm">
      <BCardHeader class="d-flex align-items-center justify-content-between">
        <div>
          <BCardTitle class="mb-1">Daftar Shift</BCardTitle>
          <p class="text-muted mb-0">Jadwal shift juru parkir per zona.</p>
        </div>
        <BButton variant="primary" @click="open(null)">
          <i class="ri-add-line me-1"></i>Tambah Shift
        </BButton>
      </BCardHeader>
      <BCardBody>
        <DataTable
          :columns="columns"
          :data="shifts"
          :sort-field="tableSortField"
          :sort-dir="tableSortDir"
          @sort="onSort"
          @search="onSearch"
          @page-change="onPage"
          @per-page-change="onPerPage"
        >
          <template #cell-user_name="{ row }">{{ row.user?.name || "-" }}</template>
          <template #cell-zone_name="{ row }">{{ row.zone?.name || "-" }}</template>
          <template #cell-shift_date="{ row }">{{ row.shift_date?.substring(0,10) || "-" }}</template>
          <template #cell-time="{ row }">{{ row.start_time?.substring(0,5) }} - {{ row.end_time?.substring(0,5) }}</template>
          <template #cell-status="{ row }">
            <span :class="`badge bg-${row.status === 'active' ? 'success' : 'secondary'}-subtle text-${row.status === 'active' ? 'success' : 'secondary'}`">{{ row.status }}</span>
          </template>
          <template #cell-actions="{ row }">
            <div class="d-flex gap-2 align-items-center">
              <button class="btn p-0 border-0 bg-transparent link-warning fs-17" @click="open(row)" title="Edit"><i class="ri-pencil-line"></i></button>
              <button class="btn p-0 border-0 bg-transparent link-danger fs-17" @click="remove(row)" title="Hapus"><i class="ri-delete-bin-line"></i></button>
            </div>
          </template>
        </DataTable>
      </BCardBody>
    </BCard>

    <BModal v-model="showModal" :title="editing ? 'Edit Shift' : 'Tambah Shift'" hide-footer>
      <div class="mb-2"><label class="form-label">Zona</label>
        <select v-model="form.zone_id" class="form-select">
          <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.name }}</option>
        </select>
      </div>
      <div class="mb-2"><label class="form-label">Jukir</label>
        <select v-model="form.user_id" class="form-select">
          <option v-for="u in users" :key="u.id" :value="u.id">{{ u.name }} ({{ u.role }})</option>
        </select>
      </div>
      <div class="mb-2"><label class="form-label">Tanggal</label><input v-model="form.shift_date" type="date" class="form-control" /></div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">Mulai</label><input v-model="form.start_time" type="time" class="form-control" /></div>
        <div class="col-6"><label class="form-label">Selesai</label><input v-model="form.end_time" type="time" class="form-control" /></div>
      </div>
      <div class="mb-3"><label class="form-label">Status</label>
        <select v-model="form.status" class="form-select">
          <option value="active">Aktif</option>
          <option value="inactive">Nonaktif</option>
        </select>
      </div>
      <div class="d-flex justify-content-end gap-2">
        <BButton variant="light" @click="showModal=false">Batal</BButton>
        <BButton variant="primary" @click="save">Simpan</BButton>
      </div>
    </BModal>
  </Layout>
</template>

<style scoped>
.stat-card { transition: transform .2s ease, box-shadow .2s ease; }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 18px 45px rgba(15, 23, 42, .12) !important; }
.avatar-sm { width: 48px; height: 48px; }
</style>
