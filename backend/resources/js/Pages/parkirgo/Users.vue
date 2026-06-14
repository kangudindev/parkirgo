<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import JukirIdCard from "@/Components/JukirIdCard.vue";
import { router } from "@inertiajs/vue3";
import Swal from "sweetalert2";

export default {
  components: { Layout, PageHeader, DataTable, JukirIdCard },
  props: {
    users: { type: Object, default: () => ({ data: [] }) },
    zones: { type: Array, default: () => [] },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
  },
  data() {
    return {
      showModal: false,
      showQrModal: false,
      showIdCardModal: false,
      editing: null,
      qrUser: null,
      cardUser: null,
      searchQuery: "",
      perPageVal: 15,
      tableSortField: this.sortField,
      tableSortDir: this.sortDir,
      form: { name: "", email: "", nik: "", phone: "", role: "jukir", status: "active", assigned_zone_id: null, password: "" },
    };
  },
  computed: {
    columns() {
      return [
        { key: "name", label: "Nama" },
        { key: "nik", label: "NIK", width: "140px" },
        { key: "role", label: "Role", width: "120px" },
        { key: "zone_name", label: "Zona" },
        { key: "status", label: "Status", width: "100px" },
        { key: "qr_status", label: "QR ID Card", sortable: false, width: "120px" },
        { key: "last_seen_at", label: "Online" },
        { key: "actions", label: "Aksi", sortable: false, width: "180px" },
      ];
    },
  },
  methods: {
    roleLabel(role) {
      const labels = { admin: "Admin ParkirGo", supervisor: "Supervisor", jukir: "Juru Parkir" };
      return labels[role] || role || "-";
    },
    statusClass(status) {
      return status === "active" ? "success" : "secondary";
    },
    formatDate(value) {
      if (!value) return "-";
      return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
    },
    open(u) {
      this.editing = u;
      if (u) this.form = { name: u.name, email: u.email, nik: u.nik || "", phone: u.phone || "", role: u.role, status: u.status, assigned_zone_id: u.assigned_zone_id, password: "" };
      else this.form = { name: "", email: "", nik: "", phone: "", role: "jukir", status: "active", assigned_zone_id: null, password: "" };
      this.showModal = true;
    },
    save() {
      if (!this.form.name || !this.form.email) {
        this.$page.props.flash = { error: "Nama dan Email harus diisi." };
        return;
      }
      if (!this.editing && !this.form.password) {
        this.$page.props.flash = { error: "Password harus diisi untuk pengguna baru." };
        return;
      }
      if (this.form.password && this.form.password.length < 6) {
        this.$page.props.flash = { error: "Password minimal 6 karakter." };
        return;
      }
      if (this.editing) {
        router.post(route("parkirgo.users.update", this.editing.id), this.form, { preserveScroll: true, onSuccess: () => this.showModal = false });
      } else {
        router.post(route("parkirgo.users.store"), this.form, { preserveScroll: true, onSuccess: () => this.showModal = false });
      }
    },
    remove(u) {
      Swal.fire({
        title: "Hapus Pengguna?",
        text: `Yakin ingin menghapus ${u.name}?`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#f06548",
        confirmButtonText: "Ya, Hapus",
        cancelButtonText: "Batal",
      }).then((r) => { if (r.isConfirmed) router.delete(route("parkirgo.users.destroy", u.id), { preserveScroll: true }); });
    },
    generateQr(userId) {
      Swal.fire({
        title: "Generate QR ID Card?",
        text: "Kartu lama akan tidak berlaku. Lanjutkan?",
        icon: "question",
        showCancelButton: true,
        confirmButtonColor: "#405189",
        confirmButtonText: "Ya, Generate",
        cancelButtonText: "Batal",
      }).then((r) => { if (r.isConfirmed) router.post(route("parkirgo.users.generate-qr", userId), {}, { preserveScroll: true }); });
    },
    revokeQr(userId) {
      Swal.fire({
        title: "Cabut QR ID Card?",
        text: "QR ID Card pengguna ini akan dinonaktifkan.",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#f06548",
        confirmButtonText: "Ya, Cabut",
        cancelButtonText: "Batal",
      }).then((r) => { if (r.isConfirmed) router.post(route("parkirgo.users.revoke-qr", userId), {}, { preserveScroll: true }); });
    },
    showIdCard(user) {
      this.cardUser = user;
      this.showIdCardModal = true;
    },
    printIdCard() {
      const printContents = document.getElementById("id-card-print-area").innerHTML;
      const printWindow = window.open("", "_blank");
      printWindow.document.write("<html><head><title>Print ID Card</title>");
      const styles = Array.from(document.styleSheets)
        .map(styleSheet => {
          try { return Array.from(styleSheet.cssRules).map(rule => rule.cssText).join(""); }
          catch (e) { return ""; }
        }).join("");
      printWindow.document.write(`<style>${styles}</style>`);
      printWindow.document.write("</head><body>");
      printWindow.document.write(printContents);
      printWindow.document.write("</body></html>");
      printWindow.document.close();
      printWindow.print();
    },
    copyToken(token) {
      navigator.clipboard.writeText(token);
    },
    onSort(field, dir) {
      this.tableSortField = field;
      this.tableSortDir = dir;
      router.get("/parkirgo/users", { sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get("/parkirgo/users", { search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal }, { preserveState: true });
    },
    onPage(page) {
      router.get("/parkirgo/users", { page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get("/parkirgo/users", { per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery }, { preserveState: true });
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="User" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total Pengguna</p>
                <h3 class="mb-0">{{ users.total || users.data?.length || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-user-settings-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Zona Aktif</p>
                <h3 class="mb-0">{{ zones.length }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-success-subtle text-success d-flex align-items-center justify-content-center">
                <i class="ri-map-pin-2-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BCard no-body class="border-0 shadow-sm">
      <BCardHeader class="d-flex align-items-center justify-content-between">
        <div>
          <BCardTitle class="mb-1">Daftar Pengguna</BCardTitle>
          <p class="text-muted mb-0">Akun admin, supervisor, dan juru parkir ParkirGo.</p>
        </div>
        <BButton variant="primary" @click="open(null)">
          <i class="ri-add-line me-1"></i>Tambah Pengguna
        </BButton>
      </BCardHeader>
      <BCardBody>
        <DataTable
          :columns="columns"
          :data="users"
          :sort-field="tableSortField"
          :sort-dir="tableSortDir"
          @sort="onSort"
          @search="onSearch"
          @page-change="onPage"
          @per-page-change="onPerPage"
        >
          <template #cell-name="{ row }">
            <div class="d-flex align-items-center gap-2">
              <img :src="row.profile_photo_url" :alt="row.name" class="rounded-circle avatar-xs" />
              <span class="fw-semibold">{{ row.name }}</span>
            </div>
          </template>
          <template #cell-role="{ row }">
            <span class="badge bg-info-subtle text-info">{{ roleLabel(row.role) }}</span>
          </template>
          <template #cell-zone_name="{ row }">{{ row.assigned_zone?.name || "-" }}</template>
          <template #cell-status="{ row }">
            <span :class="`badge bg-${statusClass(row.status)}-subtle text-${statusClass(row.status)}`">{{ row.status }}</span>
          </template>
          <template #cell-qr_status="{ row }">
            <span v-if="row.role === 'admin'" class="text-muted fst-italic">N/A</span>
            <span v-else-if="row.has_qr_token" class="badge bg-success-subtle text-success">
              <i class="ri-scanner-2-line me-1"></i>Aktif
            </span>
            <span v-else class="badge bg-warning-subtle text-warning">
              <i class="ri-scanner-2-line me-1"></i>Belum
            </span>
          </template>
          <template #cell-last_seen_at="{ row }">{{ formatDate(row.last_seen_at) }}</template>
          <template #cell-actions="{ row }">
            <div v-if="row.role !== 'admin'" class="d-flex gap-1">
              <BButton size="sm" variant="outline-secondary" @click="open(row)" title="Edit"><i class="ri-pencil-line"></i></BButton>
              <BButton v-if="!row.has_qr_token" size="sm" variant="primary" @click="generateQr(row.id)" title="Generate QR">
                <i class="ri-scanner-2-line"></i>
              </BButton>
              <BButton v-if="row.has_qr_token" size="sm" variant="outline-info" @click="showIdCard(row)" title="Cetak ID Card">
                <i class="ri-id-card-line"></i>
              </BButton>
              <BButton v-if="row.has_qr_token" size="sm" variant="outline-danger" @click="revokeQr(row.id)" title="Cabut QR">
                <i class="ri-forbid-line"></i>
              </BButton>
              <BButton size="sm" variant="outline-danger" @click="remove(row)" title="Hapus"><i class="ri-delete-bin-line"></i></BButton>
            </div>
            <span v-else class="text-muted">-</span>
          </template>
        </DataTable>
      </BCardBody>
    </BCard>

    <BModal v-model="showModal" :title="editing ? 'Edit Pengguna' : 'Tambah Pengguna'" hide-footer>
      <div class="mb-2"><label class="form-label">Nama</label><input v-model="form.name" class="form-control" /></div>
      <div class="mb-2"><label class="form-label">Email</label><input v-model="form.email" type="email" class="form-control" /></div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">NIK</label><input v-model="form.nik" class="form-control" /></div>
        <div class="col-6"><label class="form-label">Telepon</label><input v-model="form.phone" class="form-control" /></div>
      </div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">Role</label>
          <select v-model="form.role" class="form-select">
            <option value="admin">Admin ParkirGo</option>
            <option value="supervisor">Supervisor</option>
            <option value="jukir">Juru Parkir</option>
          </select>
        </div>
        <div class="col-6"><label class="form-label">Status</label>
          <select v-model="form.status" class="form-select">
            <option value="active">Aktif</option>
            <option value="inactive">Nonaktif</option>
          </select>
        </div>
      </div>
      <div class="mb-2"><label class="form-label">Zona</label>
        <select v-model="form.assigned_zone_id" class="form-select">
          <option value="">- Pilih Zona -</option>
          <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.name }}</option>
        </select>
      </div>
      <div class="mb-3">
        <label class="form-label">{{ editing ? "Password Baru (kosongkan jika tidak diubah)" : "Password" }}</label>
        <input v-model="form.password" type="password" class="form-control" />
      </div>
      <div class="d-flex justify-content-end gap-2">
        <BButton variant="light" @click="showModal=false">Batal</BButton>
        <BButton variant="primary" @click="save">Simpan</BButton>
      </div>
    </BModal>

    <BModal v-model="showIdCardModal" title="Preview ID Card Juru Parkir" hide-footer centered size="xl">
      <div v-if="cardUser" class="text-center py-3">
        <div class="d-flex justify-content-center mb-4">
          <div id="id-card-print-area">
            <JukirIdCard :user="cardUser" />
          </div>
        </div>
        <div class="d-flex justify-content-center gap-3">
          <BButton variant="light" @click="showIdCardModal=false">Tutup</BButton>
          <BButton variant="primary" @click="printIdCard">
            <i class="ri-printer-line me-1"></i>Cetak ID Card
          </BButton>
        </div>
        <p class="text-muted small mt-3">Pastikan printer terhubung dan gunakan kertas ID Card standar (CR80) untuk hasil maksimal.</p>
      </div>
    </BModal>
  </Layout>
</template>

<style scoped>
.stat-card { transition: transform .2s ease, box-shadow .2s ease; }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 18px 45px rgba(15, 23, 42, .12) !important; }
.avatar-xs { width: 32px; height: 32px; object-fit: cover; }
.avatar-sm { width: 48px; height: 48px; }
</style>
