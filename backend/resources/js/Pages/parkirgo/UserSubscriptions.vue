<script>
import { ref } from "vue";
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import MemberIdCard from "@/Components/MemberIdCard.vue";
import { router } from "@inertiajs/vue3";
import Swal from "sweetalert2";

export default {
  components: { Layout, PageHeader, DataTable, MemberIdCard },
  setup() {
    const memberCardRef = ref(null);
    return { memberCardRef };
  },
  props: {
    subscriptions: { type: Object, default: () => ({ data: [] }) },
    packages: { type: Array, default: () => [] },
    users: { type: Array, default: () => [] },
    wallets: { type: Object, default: () => ({ data: [] }) },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
  },
  data() {
    return {
      showModal: false,
      showCardModal: false,
      editing: null,
      cardSub: null,
      searchQuery: "",
      perPageVal: 15,
      tableSortField: this.sortField,
      tableSortDir: this.sortDir,
      selectedPackageId: "",
      userSearchQuery: "",
      selectedUserName: "",
      form: {
        user_id: "",
        subscription_package_id: "",
        vehicles: [],
      },
      // Edit form states
      showEditModal: false,
      editForm: {
        id: null,
        status: "active",
        value_remaining: null,
      },
    };
  },
  computed: {
    columns() {
      return [
        { key: "user", label: "Pelanggan" },
        { key: "package", label: "Paket Terdaftar" },
        { key: "vehicles", label: "Kendaraan (Plat Nomor)", sortable: false },
        { key: "duration", label: "Masa Berlaku" },
        { key: "value_remaining", label: "Sisa Kuota" },
        { key: "status", label: "Status", width: "100px" },
        { key: "actions", label: "Aksi", sortable: false, width: "120px" },
      ];
    },
    selectedPackage() {
      return this.packages.find(p => p.id === this.selectedPackageId);
    },
    isBalanceType() {
      return this.selectedPackage?.type === "balance";
    },
    maxVehicles() {
      return this.selectedPackage?.max_vehicles || 1;
    },
    filteredUsers() {
      if (!this.userSearchQuery) return this.users;
      const q = this.userSearchQuery.toLowerCase();
      return this.users.filter(u => 
        u.name.toLowerCase().includes(q) || 
        (u.email && u.email.toLowerCase().includes(q))
      );
    },
  },
  watch: {
    selectedPackageId(newVal) {
      this.form.subscription_package_id = newVal;
      this.form.vehicles = [];
      if (newVal && !this.isBalanceType) {
        const count = this.maxVehicles;
        for (let i = 0; i < count; i++) {
          this.form.vehicles.push({ license_plate: "", label: "" });
        }
      }
    },
  },
  methods: {
    formatRp(v) {
      return "Rp " + Number(v).toLocaleString("id-ID");
    },
    typeLabel(t) {
      const labels = { pass: "Unlimited Pass", quota: "Kuota Sesi", balance: "Top Up Saldo" };
      return labels[t] || t;
    },
    formatDate(d) {
      if (!d) return "-";
      return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium" }).format(new Date(d));
    },
    statusBadgeClass(s) {
      const classes = { active: "bg-success-subtle text-success", expired: "bg-danger-subtle text-danger", used_up: "bg-warning-subtle text-warning" };
      return classes[s] || "bg-secondary-subtle text-secondary";
    },
    statusLabel(s) {
      const labels = { active: "Aktif", expired: "Habis Masa Aktif", used_up: "Kuota Habis" };
      return labels[s] || s;
    },
    openCreate() {
      this.selectedPackageId = "";
      this.userSearchQuery = "";
      this.selectedUserName = "";
      this.form = {
        user_id: "",
        subscription_package_id: "",
        vehicles: [],
      };
      this.showModal = true;
    },
    selectUser(id, displayName) {
      this.form.user_id = id;
      this.selectedUserName = displayName;
    },
    openEdit(sub) {
      this.editForm = {
        id: sub.id,
        status: sub.status,
        value_remaining: sub.value_remaining,
        packageName: sub.package?.name,
        type: sub.type,
      };
      this.showEditModal = true;
    },
    save() {
      if (!this.form.subscription_package_id) {
        this.$page.props.flash = { error: "Silakan pilih paket terlebih dahulu." };
        return;
      }

      if (this.isBalanceType && !this.form.user_id) {
        this.$page.props.flash = { error: "Top Up Saldo memerlukan pengguna yang dipilih." };
        return;
      }

      // Bersihkan list plat kosong
      if (!this.isBalanceType) {
        this.form.vehicles = this.form.vehicles.filter(v => v.license_plate.trim() !== "");
        if (this.form.vehicles.length === 0) {
          this.$page.props.flash = { error: "Silakan masukkan minimal 1 plat nomor kendaraan." };
          return;
        }
      }

      router.post(route("parkirgo.user-subscriptions.store"), this.form, {
        preserveScroll: true,
        onSuccess: () => {
          this.showModal = false;
          Swal.fire("Berhasil", "Data berhasil diproses.", "success");
        },
      });
    },
    updateSub() {
      router.put(route("parkirgo.user-subscriptions.update", this.editForm.id), this.editForm, {
        preserveScroll: true,
        onSuccess: () => {
          this.showEditModal = false;
          Swal.fire("Diperbarui", "Data langganan berhasil diperbarui.", "success");
        },
      });
    },
    showMemberCard(sub) {
      this.cardSub = sub;
      this.showCardModal = true;
    },
    downloadMemberCard() {
      if (this.memberCardRef) {
        this.memberCardRef.downloadCard();
      }
    },
    remove(sub) {
      Swal.fire({
        title: "Hapus Langganan?",
        text: "Menghapus langganan akan menghentikan akses parkir gratis kendaraan terdaftar.",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#f06548",
        confirmButtonText: "Ya, Hapus",
        cancelButtonText: "Batal",
      }).then((r) => {
        if (r.isConfirmed) {
          router.delete(route("parkirgo.user-subscriptions.destroy", sub.id), { preserveScroll: true });
        }
      });
    },
    onSort(field, dir) {
      this.tableSortField = field;
      this.tableSortDir = dir;
      router.get(route("parkirgo.user-subscriptions"), { sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get(route("parkirgo.user-subscriptions"), { search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal }, { preserveState: true });
    },
    onPage(page) {
      router.get(route("parkirgo.user-subscriptions"), { page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get(route("parkirgo.user-subscriptions"), { per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery }, { preserveState: true });
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Pelanggan & Kendaraan Langganan" pageTitle="Manajemen Berlangganan" />

    <BRow class="g-4">
      <!-- Kolom Utama: Pelanggan Aktif -->
      <BCol lg="8">
        <BCard no-body class="border-0 shadow-sm mb-4">
          <BCardHeader class="d-flex align-items-center justify-content-between">
            <div>
              <BCardTitle class="mb-1">Pelanggan Aktif</BCardTitle>
              <p class="text-muted mb-0">Daftar plat nomor kendaraan terdaftar dengan paket Unlimited Pass atau Kuota.</p>
            </div>
            <BButton variant="primary" @click="openCreate">
              <i class="ri-add-line me-1"></i>Registrasi Langganan
            </BButton>
          </BCardHeader>
          <BCardBody>
            <DataTable
              :columns="columns"
              :data="subscriptions"
              :sort-field="tableSortField"
              :sort-dir="tableSortDir"
              @sort="onSort"
              @search="onSearch"
              @page-change="onPage"
              @per-page-change="onPerPage"
            >
              <template #cell-user="{ row }">
                <div v-if="row.user" class="fw-semibold">{{ row.user.name }}<br><small class="text-muted">{{ row.user.email }}</small></div>
                <div v-else class="text-muted fst-italic">Pelanggan Offline</div>
              </template>
              <template #cell-package="{ row }">
                <span class="fw-semibold">{{ row.package?.name || "-" }}</span><br>
                <small class="text-muted text-uppercase">{{ row.package?.type }} Pass</small>
              </template>
              <template #cell-vehicles="{ row }">
                <div class="d-flex flex-wrap gap-2">
                  <span v-for="v in row.vehicles" :key="v.id" class="badge bg-light text-dark border px-2 py-1" :title="v.label">
                    <i class="ri-car-line text-primary me-1 align-middle"></i>
                    <span class="fw-bold fs-11">{{ v.license_plate }}</span>
                    <span v-if="v.label" class="text-muted ms-1 fs-10">({{ v.label }})</span>
                  </span>
                </div>
              </template>
              <template #cell-duration="{ row }">
                <small class="text-dark d-block">Mulai: {{ formatDate(row.start_date) }}</small>
                <small class="text-danger d-block">Akhir: {{ formatDate(row.end_date) }}</small>
              </template>
              <template #cell-value_remaining="{ row }">
                <span v-if="row.type === 'quota'" class="fw-bold text-info fs-14">{{ row.value_remaining }} Sesi</span>
                <span v-else class="text-muted">Unlimited</span>
              </template>
              <template #cell-status="{ row }">
                <span :class="`badge ${statusBadgeClass(row.status)}`">{{ statusLabel(row.status) }}</span>
              </template>
              <template #cell-actions="{ row }">
                <div class="d-flex gap-1">
                  <BButton size="sm" variant="outline-info" @click="showMemberCard(row)" title="Cetak Kartu Member"><i class="ri-printer-line"></i></BButton>
                  <BButton size="sm" variant="outline-secondary" @click="openEdit(row)" title="Edit Status/Kuota"><i class="ri-pencil-line"></i></BButton>
                  <BButton size="sm" variant="outline-danger" @click="remove(row)" title="Hapus"><i class="ri-delete-bin-line"></i></BButton>
                </div>
              </template>
            </DataTable>
          </BCardBody>
        </BCard>
      </BCol>

      <!-- Kolom Kanan: Saldo Dompet Pengguna -->
      <BCol lg="4">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader class="bg-transparent border-bottom">
            <BCardTitle class="mb-0"><i class="ri-wallet-3-line text-primary me-2 fs-18 align-middle"></i>Dompet Prabayar Pengguna</BCardTitle>
          </BCardHeader>
          <BCardBody class="p-0">
            <div v-if="(wallets.data || []).length" class="list-group list-group-flush">
              <div v-for="w in wallets.data || wallets" :key="w.id" class="list-group-item py-3">
                <div class="d-flex align-items-center justify-content-between">
                  <div>
                    <h6 class="mb-0 fw-semibold">{{ w.user?.name || "User Tidak Dikenal" }}</h6>
                    <small class="text-muted d-block">{{ w.user?.email }}</small>
                  </div>
                  <div>
                    <span class="fs-15 fw-bold text-success">{{ formatRp(w.balance) }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="text-center py-5 text-muted">
              <i class="ri-wallet-3-line fs-36 d-block mb-2 text-secondary"></i>
              Belum ada pengguna yang memiliki saldo dompet.
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <!-- Modal Registrasi Pelanggan Baru -->
    <BModal v-model="showModal" title="Registrasi Berlangganan Baru" hide-footer size="lg">
      <div class="mb-3">
        <label class="form-label fw-medium">Pilih Paket Langganan</label>
        <select v-model="selectedPackageId" class="form-select">
          <option value="">-- Pilih Paket --</option>
          <option v-for="p in packages" :key="p.id" :value="p.id">
            {{ p.name }} - {{ formatRp(p.price) }} ({{ typeLabel(p.type) }} - Maks. {{ p.max_vehicles }} Kendaraan)
          </option>
        </select>
      </div>

      <div class="mb-3">
        <label class="form-label fw-medium">Pengguna Terdaftar (Optional untuk Pass/Kuota, Wajib untuk Top Up)</label>
        <div class="dropdown">
          <button class="btn btn-outline-secondary w-100 text-start d-flex justify-content-between align-items-center dropdown-toggle bg-white text-dark border-secondary-subtle" 
                  type="button" 
                  data-bs-toggle="dropdown" 
                  aria-expanded="false">
            <span>{{ selectedUserName || '-- Pengguna Offline (Tanpa Akun) --' }}</span>
          </button>
          
          <div class="dropdown-menu w-100 p-2 shadow-lg" style="max-height: 250px; overflow-y: auto; z-index: 1060;">
            <!-- Search Input -->
            <input v-model="userSearchQuery" 
                   type="text" 
                   class="form-control form-control-sm mb-2" 
                   placeholder="Cari nama atau email..." 
                   @click.stop />
                   
            <!-- Default Option -->
            <button class="dropdown-item py-2 border-bottom border-light" 
                    type="button" 
                    @click="selectUser('', '')">
              -- Pengguna Offline (Tanpa Akun) --
            </button>
            
            <!-- List Users -->
            <button v-for="u in filteredUsers" 
                    :key="u.id" 
                    class="dropdown-item py-2 border-bottom border-light" 
                    type="button" 
                    @click="selectUser(u.id, `${u.name} (${u.email})`)">
              <div class="fw-semibold fs-12">{{ u.name }}</div>
              <small class="text-muted fs-11">{{ u.email }}</small>
            </button>
            
            <!-- No results -->
            <div v-if="filteredUsers.length === 0" class="text-muted text-center py-2 fs-11">
              Tidak ada pengguna ditemukan.
            </div>
          </div>
        </div>
      </div>

      <!-- Form Kendaraan Dinamis berdasarkan batas kendaraan paket -->
      <div v-if="selectedPackageId && !isBalanceType" class="mb-4">
        <label class="form-label fw-semibold text-primary"><i class="ri-car-fill me-1 align-middle"></i> Registrasi Plat Nomor Kendaraan (Maks. {{ maxVehicles }} Slot)</label>
        <div class="border rounded p-3 bg-light">
          <div v-for="(v, i) in form.vehicles" :key="i" class="row g-2 mb-2 align-items-center">
            <div class="col-sm-1"><span class="fw-bold text-secondary">#{{ i + 1 }}</span></div>
            <div class="col-sm-5">
              <input v-model="v.license_plate" class="form-control form-control-sm text-uppercase" placeholder="Contoh: B1234XYZ" />
            </div>
            <div class="col-sm-6">
              <input v-model="v.label" class="form-control form-control-sm" placeholder="Label, Contoh: Mobil Utama" />
            </div>
          </div>
          <small class="text-muted d-block mt-2">Daftarkan plat nomor kendaraan di atas. Kosongkan baris jika tidak diperlukan (min. 1 terisi).</small>
        </div>
      </div>

      <div v-if="isBalanceType" class="alert alert-info py-2">
        <i class="ri-information-line me-1 align-middle"></i> Paket ini bertipe <b>Top Up Saldo</b>. Setelah disimpan, nominal saldo paket akan otomatis ditambahkan ke dompet pengguna yang dipilih.
      </div>

      <div class="d-flex justify-content-end gap-2 mt-4">
        <BButton variant="light" @click="showModal = false">Batal</BButton>
        <BButton variant="primary" @click="save" :disabled="!selectedPackageId">Simpan Langganan</BButton>
      </div>
    </BModal>

    <!-- Modal Edit Langganan Aktif -->
    <BModal v-model="showEditModal" :title="`Edit Langganan - ${editForm.packageName}`" hide-footer>
      <div class="mb-3">
        <label class="form-label fw-medium">Status Langganan</label>
        <select v-model="editForm.status" class="form-select">
          <option value="active">Aktif</option>
          <option value="expired">Habis Masa Aktif</option>
          <option value="used_up">Kuota Habis</option>
        </select>
      </div>

      <div v-if="editForm.type === 'quota'" class="mb-3">
        <label class="form-label fw-medium">Sisa Kuota (Sesi Parkir)</label>
        <input v-model.number="editForm.value_remaining" type="number" min="0" class="form-control" />
      </div>

      <div class="d-flex justify-content-end gap-2 mt-4">
        <BButton variant="light" @click="showEditModal = false">Batal</BButton>
        <BButton variant="primary" @click="updateSub">Simpan Perubahan</BButton>
      </div>
    </BModal>

    <!-- Modal Preview Kartu Member -->
    <BModal v-model="showCardModal" title="Preview Kartu Member" hide-footer centered size="xl">
      <div v-if="cardSub" class="text-center py-3">
        <div class="d-flex justify-content-center mb-4">
          <MemberIdCard ref="memberCardRef" :subscription="cardSub" />
        </div>
        <div class="d-flex justify-content-center gap-3">
          <BButton variant="light" @click="showCardModal=false">Tutup</BButton>
          <BButton variant="primary" @click="downloadMemberCard">
            <i class="ri-download-2-line me-1"></i>Download Kartu Member (PNG)
          </BButton>
        </div>
        <p class="text-muted small mt-3">Kartu member dapat diunduh dalam format gambar berkualitas tinggi untuk dicetak.</p>
      </div>
    </BModal>
  </Layout>
</template>

<style scoped>
.avatar-xs {
  width: 32px;
  height: 32px;
}
</style>
