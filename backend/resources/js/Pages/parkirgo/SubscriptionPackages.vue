<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import { router } from "@inertiajs/vue3";
import Swal from "sweetalert2";

export default {
  components: { Layout, PageHeader, DataTable },
  props: {
    packages: { type: Object, default: () => ({ data: [] }) },
    vehicleTypes: { type: Array, default: () => [] },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
  },
  data() {
    return {
      showModal: false,
      editing: null,
      searchQuery: "",
      perPageVal: 15,
      tableSortField: this.sortField,
      tableSortDir: this.sortDir,
      form: {
        name: "",
        type: "pass",
        price: 0,
        duration_days: 30,
        max_vehicles: 1,
        value: null,
        vehicle_type_id: "",
        status: "active",
        description: "",
      },
    };
  },
  computed: {
    columns() {
      return [
        { key: "name", label: "Nama Paket" },
        { key: "type", label: "Tipe Paket", width: "120px" },
        { key: "vehicle_type", label: "Jenis Kendaraan", width: "150px" },
        { key: "price", label: "Harga", width: "130px" },
        { key: "duration_days", label: "Masa Aktif", width: "110px" },
        { key: "max_vehicles", label: "Maks. Kendaraan", width: "130px" },
        { key: "value", label: "Manfaat/Kuota" },
        { key: "status", label: "Status", width: "100px" },
        { key: "actions", label: "Aksi", sortable: false, width: "120px" },
      ];
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
    typeBadgeClass(t) {
      const classes = { pass: "success", quota: "info", balance: "warning" };
      return `bg-${classes[t] || "secondary"}-subtle text-${classes[t] || "secondary"}`;
    },
    statusBadgeClass(s) {
      return s === "active" ? "bg-success-subtle text-success" : "bg-danger-subtle text-danger";
    },
    open(pkg) {
      this.editing = pkg;
      if (pkg) {
        this.form = {
          name: pkg.name,
          type: pkg.type,
          price: pkg.price,
          duration_days: pkg.duration_days,
          max_vehicles: pkg.max_vehicles,
          value: pkg.value,
          vehicle_type_id: pkg.vehicle_type_id,
          status: pkg.status,
          description: pkg.description || "",
        };
      } else {
        this.form = {
          name: "",
          type: "pass",
          price: 0,
          duration_days: 30,
          max_vehicles: 1,
          value: null,
          vehicle_type_id: this.vehicleTypes[0]?.id || "",
          status: "active",
          description: "",
        };
      }
      this.showModal = true;
    },
    save() {
      if (!this.form.name || !this.form.vehicle_type_id) {
        this.$page.props.flash = { error: "Nama paket dan tipe kendaraan harus diisi." };
        return;
      }

      if (this.editing) {
        router.put(route("parkirgo.subscription-packages.update", this.editing.id), this.form, {
          preserveScroll: true,
          onSuccess: () => this.showModal = false,
        });
      } else {
        router.post(route("parkirgo.subscription-packages.store"), this.form, {
          preserveScroll: true,
          onSuccess: () => this.showModal = false,
        });
      }
    },
    remove(pkg) {
      Swal.fire({
        title: "Hapus Paket?",
        text: `Yakin ingin menghapus paket ${pkg.name}? Paket yang terhubung dengan data pelanggan tidak bisa dihapus.`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#f06548",
        confirmButtonText: "Ya, Hapus",
        cancelButtonText: "Batal",
      }).then((r) => {
        if (r.isConfirmed) {
          router.delete(route("parkirgo.subscription-packages.destroy", pkg.id), { preserveScroll: true });
        }
      });
    },
    onSort(field, dir) {
      this.tableSortField = field;
      this.tableSortDir = dir;
      router.get(route("parkirgo.subscription-packages"), { sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get(route("parkirgo.subscription-packages"), { search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal }, { preserveState: true });
    },
    onPage(page) {
      router.get(route("parkirgo.subscription-packages"), { page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get(route("parkirgo.subscription-packages"), { per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery }, { preserveState: true });
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Paket Berlangganan" pageTitle="Manajemen Berlangganan" />

    <BCard no-body class="border-0 shadow-sm mb-4">
      <BCardHeader class="d-flex align-items-center justify-content-between">
        <div>
          <BCardTitle class="mb-1">Paket Berlangganan</BCardTitle>
          <p class="text-muted mb-0">Konfigurasi jenis paket langganan parkir terusan, kuota, atau top-up saldo.</p>
        </div>
        <BButton variant="primary" @click="open(null)">
          <i class="ri-add-line me-1"></i>Tambah Paket
        </BButton>
      </BCardHeader>
      <BCardBody>
        <DataTable
          :columns="columns"
          :data="packages"
          :sort-field="tableSortField"
          :sort-dir="tableSortDir"
          @sort="onSort"
          @search="onSearch"
          @page-change="onPage"
          @per-page-change="onPerPage"
        >
          <template #cell-type="{ row }">
            <span :class="`badge ${typeBadgeClass(row.type)} px-2 py-1`">{{ typeLabel(row.type) }}</span>
          </template>
          <template #cell-vehicle_type="{ row }">
            <span class="fw-semibold">
              <i :class="row.vehicle_type?.icon || 'ri-car-line'" class="text-primary me-1 fs-15"></i>
              {{ row.vehicle_type?.name || "-" }}
            </span>
          </template>
          <template #cell-price="{ row }">{{ formatRp(row.price) }}</template>
          <template #cell-duration_days="{ row }">{{ row.duration_days }} Hari</template>
          <template #cell-max_vehicles="{ row }">
            <span class="badge bg-light text-dark fw-semibold px-2 py-1">
              <i class="ri-car-fill me-1 align-middle text-secondary"></i> {{ row.max_vehicles }} Slot
            </span>
          </template>
          <template #cell-value="{ row }">
            <span v-if="row.type === 'quota'" class="fw-semibold text-info">{{ Number(row.value) }} Sesi Parkir</span>
            <span v-else-if="row.type === 'balance'" class="fw-semibold text-success">+{{ formatRp(row.value) }} Saldo</span>
            <span v-else class="text-muted">Unlimited</span>
          </template>
          <template #cell-status="{ row }">
            <span :class="`badge ${statusBadgeClass(row.status)}`">{{ row.status === 'active' ? 'Aktif' : 'Nonaktif' }}</span>
          </template>
          <template #cell-actions="{ row }">
            <div class="d-flex gap-2 align-items-center">
              <button class="btn p-0 border-0 bg-transparent link-warning fs-17" @click="open(row)" title="Edit Paket"><i class="ri-pencil-line"></i></button>
              <button class="btn p-0 border-0 bg-transparent link-danger fs-17" @click="remove(row)" title="Hapus Paket"><i class="ri-delete-bin-line"></i></button>
            </div>
          </template>
        </DataTable>
      </BCardBody>
    </BCard>

    <!-- Modal Form Tambah/Edit -->
    <BModal v-model="showModal" :title="editing ? 'Edit Paket Langganan' : 'Tambah Paket Langganan'" hide-footer size="lg">
      <div class="row g-3 mb-3">
        <div class="col-md-6">
          <label class="form-label fw-medium">Nama Paket</label>
          <input v-model="form.name" class="form-control" placeholder="Contoh: Bulanan Motor Unlimited" />
        </div>
        <div class="col-md-6">
          <label class="form-label fw-medium">Jenis Kendaraan</label>
          <select v-model="form.vehicle_type_id" class="form-select">
            <option v-for="vt in vehicleTypes" :key="vt.id" :value="vt.id">{{ vt.name }}</option>
          </select>
        </div>
      </div>

      <div class="row g-3 mb-3">
        <div class="col-md-4">
          <label class="form-label fw-medium">Tipe Paket</label>
          <select v-model="form.type" class="form-select">
            <option value="pass">Unlimited Pass (Terusan)</option>
            <option value="quota">Kuota Sesi Parkir</option>
            <option value="balance">Top Up Saldo Elektronik</option>
          </select>
        </div>
        <div class="col-md-4">
          <label class="form-label fw-medium">Harga Jual (Rp)</label>
          <input v-model.number="form.price" type="number" min="0" class="form-control" />
        </div>
        <div class="col-md-4">
          <label class="form-label fw-medium">Masa Aktif (Hari)</label>
          <input v-model.number="form.duration_days" type="number" min="1" class="form-control" />
        </div>
      </div>

      <div class="row g-3 mb-3">
        <div class="col-md-6" v-if="form.type !== 'balance'">
          <label class="form-label fw-medium">Maksimal Kendaraan Terdaftar</label>
          <input v-model.number="form.max_vehicles" type="number" min="1" class="form-control" />
          <small class="text-muted">Batas plat nomor kendaraan berbeda yang bisa dimasukkan.</small>
        </div>
        <div class="col-md-6" v-if="form.type !== 'pass'">
          <label class="form-label fw-medium">
            {{ form.type === 'quota' ? 'Jumlah Kuota Sesi' : 'Jumlah Saldo Tambahan (Rp)' }}
          </label>
          <input v-model.number="form.value" type="number" min="1" class="form-control" />
          <small class="text-muted">Nilai saldo prabayar atau jumlah sesi gratis yang diperoleh.</small>
        </div>
        <div class="col-md-6">
          <label class="form-label fw-medium">Status Paket</label>
          <select v-model="form.status" class="form-select">
            <option value="active">Aktif</option>
            <option value="inactive">Nonaktif</option>
          </select>
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label fw-medium">Deskripsi Paket</label>
        <textarea v-model="form.description" class="form-control" rows="3" placeholder="Penjelasan singkat mengenai manfaat paket ini..."></textarea>
      </div>

      <div class="d-flex justify-content-end gap-2 mt-4">
        <BButton variant="light" @click="showModal = false">Batal</BButton>
        <BButton variant="primary" @click="save">Simpan Paket</BButton>
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
