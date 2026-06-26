<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import JukirIdCard from "@/Components/JukirIdCard.vue";
import { ref } from "vue";
import { router } from "@inertiajs/vue3";
import Swal from "sweetalert2";

export default {
  components: { Layout, PageHeader, DataTable, JukirIdCard },
  setup() {
    const idCardRef = ref(null);
    return { idCardRef };
  },
  props: {
    users: { type: Object, default: () => ({ data: [] }) },
    zones: { type: Array, default: () => [] },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
    currentTab: { type: String, default: "staff" },
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
      if (this.currentTab === "customer") {
        return [
          { key: "name", label: "Nama Member" },
          { key: "email", label: "Email" },
          { key: "phone", label: "Telepon" },
          { key: "status", label: "Status", width: "100px" },
          { key: "created_at", label: "Tanggal Daftar" },
          { key: "actions", label: "Aksi", sortable: false, width: "120px" },
        ];
      }
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
      const labels = { admin: "Admin ParkirGo", supervisor: "Supervisor", jukir: "Juru Parkir", customer: "Member Langganan" };
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
      else this.form = { name: "", email: "", nik: "", phone: "", role: this.currentTab === "customer" ? "customer" : "jukir", status: "active", assigned_zone_id: null, password: "" };
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
    downloadIdCard() {
      if (this.idCardRef) {
        this.idCardRef.downloadCard();
      }
    },
    changeTab(tab) {
      router.get("/parkirgo/users", { tab, search: this.searchQuery, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal });
    },
    onSort(field, dir) {
      this.tableSortField = field;
      this.tableSortDir = dir;
      router.get("/parkirgo/users", { tab: this.currentTab, sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get("/parkirgo/users", { tab: this.currentTab, search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal }, { preserveState: true });
    },
    onPage(page) {
      router.get("/parkirgo/users", { tab: this.currentTab, page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get("/parkirgo/users", { tab: this.currentTab, per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery }, { preserveState: true });
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="User" pageTitle="ParkirGo" />

    <div class="row mb-4" v-if="$page.props.auth.user.role === 'admin'">
      <div class="col-md-12">
        <BCard no-body class="border-0 shadow-sm bg-primary-subtle">
          <BCardBody class="p-3">
             <div class="d-flex align-items-center">
                <div class="flex-shrink-0">
                   <img :src="$page.props.auth.user.profile_photo_url" class="rounded-circle avatar-md img-thumbnail" alt="">
                </div>
                <div class="flex-grow-1 ms-3">
                   <h4 class="mb-1 text-primary fw-bold">{{ $page.props.auth.user.name }}</h4>
                   <p class="text-muted mb-0 text-capitalize">{{ $page.props.auth.user.role }} Dashboard Control</p>
                </div>
             </div>
          </BCardBody>
        </BCard>
      </div>
    </div>

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
          <BCardTitle class="mb-1">{{ currentTab === 'customer' ? 'Daftar Member Berlangganan' : 'Daftar Pengguna Jukir & Staf' }}</BCardTitle>
          <p class="text-muted mb-0">{{ currentTab === 'customer' ? 'Kelola akun pengendara/member terdaftar ParkirGo.' : 'Akun admin, supervisor, dan juru parkir ParkirGo.' }}</p>
        </div>
        <BButton variant="primary" @click="open(null)">
          <i class="ri-add-line me-1"></i>{{ currentTab === 'customer' ? 'Tambah Member' : 'Tambah Pengguna' }}
        </BButton>
      </BCardHeader>
      <BCardBody>
        <!-- Tab Navigation -->
        <ul class="nav nav-tabs nav-tabs-custom nav-success mb-3" role="tablist">
          <li class="nav-item">
            <a class="nav-link" :class="{ active: currentTab === 'staff' }" @click="changeTab('staff')" href="javascript:void(0);">
              <i class="ri-user-settings-line me-1 align-bottom"></i> Jukir & Staf
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" :class="{ active: currentTab === 'customer' }" @click="changeTab('customer')" href="javascript:void(0);">
              <i class="ri-user-star-line me-1 align-bottom"></i> Member Berlangganan
            </a>
          </li>
        </ul>

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
          <template #cell-created_at="{ row }">{{ formatDate(row.created_at) }}</template>
          <template #cell-actions="{ row }">
            <div v-if="row.role === 'customer'" class="d-flex gap-1">
              <BButton size="sm" variant="outline-secondary" @click="open(row)" title="Edit Member"><i class="ri-pencil-line"></i></BButton>
              <BButton size="sm" variant="outline-danger" @click="remove(row)" title="Hapus"><i class="ri-delete-bin-line"></i></BButton>
            </div>
            <div v-else-if="row.role !== 'admin'" class="d-flex gap-1">
              <BButton size="sm" variant="outline-secondary" @click="open(row)" title="Edit"><i class="ri-pencil-line"></i></BButton>
              <BButton v-if="!row.has_qr_token" size="sm" variant="primary" @click="generateQr(row.id)" title="Generate QR">
                <i class="ri-scanner-2-line"></i>
              </BButton>
              <BButton v-if="row.has_qr_token" size="sm" variant="outline-info" @click="showIdCard(row)" title="Cetak ID Card">
                <i class="ri-printer-line"></i>
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

    <BModal v-model="showModal" :title="editing ? (form.role === 'customer' ? 'Edit Member Berlangganan' : 'Edit Pengguna') : (currentTab === 'customer' ? 'Tambah Member Berlangganan Baru' : 'Tambah Pengguna Baru')" hide-footer>
      <div class="mb-2"><label class="form-label">Nama</label><input v-model="form.name" class="form-control" /></div>
      <div class="mb-2"><label class="form-label">Email</label><input v-model="form.email" type="email" class="form-control" /></div>
      <div class="row mb-2">
        <div class="col-6" v-if="form.role !== 'customer'"><label class="form-label">NIK</label><input v-model="form.nik" class="form-control" /></div>
        <div class="col-6" :class="{ 'col-12': form.role === 'customer' }"><label class="form-label">Telepon</label><input v-model="form.phone" class="form-control" /></div>
      </div>
      <div class="row mb-2" v-if="form.role !== 'customer'">
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
      <div class="row mb-2" v-else>
        <div class="col-12"><label class="form-label">Status</label>
          <select v-model="form.status" class="form-select">
            <option value="active">Aktif</option>
            <option value="inactive">Nonaktif</option>
          </select>
        </div>
      </div>
      <div class="mb-2" v-if="form.role !== 'customer'"><label class="form-label">Zona</label>
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
          <JukirIdCard ref="idCardRef" :user="cardUser" />
        </div>
        <div class="d-flex justify-content-center gap-3">
          <BButton variant="light" @click="showIdCardModal=false">Tutup</BButton>
          <BButton variant="primary" @click="downloadIdCard">
            <i class="ri-download-2-line me-1"></i>Download ID Card (PNG)
          </BButton>
        </div>
        <p class="text-muted small mt-3">ID Card dapat diunduh dalam format gambar berkualitas tinggi untuk dicetak.</p>
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
