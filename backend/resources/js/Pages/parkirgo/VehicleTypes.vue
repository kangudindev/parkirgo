<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { router, useForm } from "@inertiajs/vue3";

const emptyForm = () => ({
  code: "",
  name: "",
  icon: "ri-car-line",
  sort_order: 0,
  status: "active",
});

export default {
  components: { Layout, PageHeader },
  props: {
    vehicleTypes: { type: Array, default: () => [] },
  },
  data() {
    return {
      modalOpen: false,
      deleteModalOpen: false,
      editingType: null,
      deletingType: null,
      form: useForm(emptyForm()),
    };
  },
  computed: {
    activeCount() {
      return this.vehicleTypes.filter((type) => type.status === "active").length;
    },
    inactiveCount() {
      return this.vehicleTypes.filter((type) => type.status === "inactive").length;
    },
    sortedTypes() {
      return [...this.vehicleTypes].sort((a, b) => (a.sort_order ?? 0) - (b.sort_order ?? 0));
    },
  },
  methods: {
    openCreate() {
      this.editingType = null;
      this.form = useForm(emptyForm());
      this.modalOpen = true;
    },
    openEdit(type) {
      this.editingType = type;
      this.form = useForm({
        code: type.code || "",
        name: type.name || "",
        icon: type.icon || "ri-car-line",
        sort_order: type.sort_order ?? 0,
        status: type.status || "active",
      });
      this.modalOpen = true;
    },
    submit() {
      const options = {
        preserveScroll: true,
        onSuccess: () => {
          this.modalOpen = false;
          this.form.reset();
        },
      };

      if (this.editingType) {
        this.form.put(`/parkirgo/vehicle-types/${this.editingType.id}`, options);
        return;
      }

      this.form.post("/parkirgo/vehicle-types", options);
    },
    askDelete(type) {
      this.deletingType = type;
      this.deleteModalOpen = true;
    },
    destroyType() {
      if (!this.deletingType) return;
      router.delete(`/parkirgo/vehicle-types/${this.deletingType.id}`, {
        preserveScroll: true,
        onSuccess: () => {
          this.deleteModalOpen = false;
          this.deletingType = null;
        },
      });
    },
    statusClass(status) {
      return status === "active" ? "success" : "secondary";
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Master Jenis Kendaraan" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol xl="4" md="6">
        <BCard no-body class="border-0 overflow-hidden vehicle-hero text-white h-100">
          <BCardBody>
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <p class="text-white-75 mb-2">Total Master</p>
                <h2 class="text-white mb-1">{{ vehicleTypes.length }}</h2>
                <span class="badge bg-white text-success">Tarif & Offline Sync Ready</span>
              </div>
              <div class="vehicle-hero-icon">
                <i class="ri-roadster-line"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="4" md="6">
        <BCard no-body class="border-0 shadow-sm h-100 stat-card">
          <BCardBody class="d-flex align-items-center justify-content-between">
            <div>
              <p class="text-muted mb-1">Aktif Digunakan</p>
              <h3 class="mb-0">{{ activeCount }}</h3>
            </div>
            <div class="avatar-sm rounded-circle bg-success-subtle text-success d-flex align-items-center justify-content-center">
              <i class="ri-checkbox-circle-line fs-22"></i>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="4" md="12">
        <BCard no-body class="border-0 shadow-sm h-100 stat-card">
          <BCardBody class="d-flex align-items-center justify-content-between">
            <div>
              <p class="text-muted mb-1">Dinonaktifkan</p>
              <h3 class="mb-0">{{ inactiveCount }}</h3>
            </div>
            <div class="avatar-sm rounded-circle bg-warning-subtle text-warning d-flex align-items-center justify-content-center">
              <i class="ri-pause-circle-line fs-22"></i>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BCard no-body class="border-0 shadow-sm master-card">
      <BCardHeader class="align-items-center d-flex">
        <div class="flex-grow-1">
          <BCardTitle class="mb-1">Daftar Jenis Kendaraan</BCardTitle>
          <p class="text-muted mb-0 small">Kode dipakai sebagai snapshot offline pada sesi parkir dan tarif zona.</p>
        </div>
        <BButton id="vehicle-type-create-button" variant="success" class="btn-label" @click="openCreate">
          <i class="ri-add-line label-icon align-middle fs-16 me-2"></i>
          Tambah Jenis
        </BButton>
      </BCardHeader>
      <BCardBody>
        <div class="table-responsive table-card">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr>
                <th style="width: 70px;">Urut</th>
                <th>Jenis Kendaraan</th>
                <th>Kode</th>
                <th>Status</th>
                <th>Diperbarui</th>
                <th class="text-end">Aksi</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="type in sortedTypes" :key="type.id">
                <td><span class="badge bg-light text-dark">{{ type.sort_order ?? 0 }}</span></td>
                <td>
                  <div class="d-flex align-items-center gap-3">
                    <div class="vehicle-icon">
                      <i :class="type.icon || 'ri-car-line'"></i>
                    </div>
                    <div>
                      <h6 class="mb-0">{{ type.name }}</h6>
                      <small class="text-muted">Master tarif parkir</small>
                    </div>
                  </div>
                </td>
                <td><code>{{ type.code }}</code></td>
                <td>
                  <span class="badge text-capitalize" :class="`bg-${statusClass(type.status)}-subtle text-${statusClass(type.status)}`">
                    {{ type.status }}
                  </span>
                </td>
                <td>{{ type.updated_at ? new Date(type.updated_at).toLocaleString('id-ID') : '-' }}</td>
                <td class="text-end">
                  <BButton :id="`vehicle-type-edit-${type.id}`" size="sm" variant="soft-primary" class="me-2" @click="openEdit(type)">
                    <i class="ri-pencil-line"></i>
                  </BButton>
                  <BButton :id="`vehicle-type-delete-${type.id}`" size="sm" variant="soft-danger" @click="askDelete(type)">
                    <i class="ri-delete-bin-line"></i>
                  </BButton>
                </td>
              </tr>
              <tr v-if="sortedTypes.length === 0">
                <td colspan="6" class="text-center py-5 text-muted">Belum ada master jenis kendaraan.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </BCardBody>
    </BCard>

    <BModal v-model="modalOpen" :title="editingType ? 'Edit Jenis Kendaraan' : 'Tambah Jenis Kendaraan'" hide-footer centered header-class="p-3 bg-light">
      <form id="vehicle-type-form" @submit.prevent="submit">
        <BRow class="g-3">
          <BCol lg="6">
            <label for="vehicle-type-code" class="form-label">Kode</label>
            <input id="vehicle-type-code" v-model="form.code" type="text" class="form-control" placeholder="motor" />
            <div v-if="form.errors.code" class="text-danger small mt-1">{{ form.errors.code }}</div>
          </BCol>
          <BCol lg="6">
            <label for="vehicle-type-name" class="form-label">Nama</label>
            <input id="vehicle-type-name" v-model="form.name" type="text" class="form-control" placeholder="Motor" />
            <div v-if="form.errors.name" class="text-danger small mt-1">{{ form.errors.name }}</div>
          </BCol>
          <BCol lg="6">
            <label for="vehicle-type-icon" class="form-label">Icon Remix</label>
            <input id="vehicle-type-icon" v-model="form.icon" type="text" class="form-control" placeholder="ri-motorbike-line" />
            <div v-if="form.errors.icon" class="text-danger small mt-1">{{ form.errors.icon }}</div>
          </BCol>
          <BCol lg="3">
            <label for="vehicle-type-sort" class="form-label">Urutan</label>
            <input id="vehicle-type-sort" v-model.number="form.sort_order" type="number" min="0" class="form-control" />
            <div v-if="form.errors.sort_order" class="text-danger small mt-1">{{ form.errors.sort_order }}</div>
          </BCol>
          <BCol lg="3">
            <label for="vehicle-type-status" class="form-label">Status</label>
            <select id="vehicle-type-status" v-model="form.status" class="form-select">
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
            <div v-if="form.errors.status" class="text-danger small mt-1">{{ form.errors.status }}</div>
          </BCol>
        </BRow>
        <div class="d-flex justify-content-end gap-2 mt-4">
          <BButton id="vehicle-type-cancel-button" variant="light" type="button" @click="modalOpen = false">Batal</BButton>
          <BButton id="vehicle-type-submit-button" variant="success" type="submit" :disabled="form.processing">
            {{ form.processing ? 'Menyimpan...' : 'Simpan' }}
          </BButton>
        </div>
      </form>
    </BModal>

    <BModal v-model="deleteModalOpen" hide-footer centered header-class="p-3 bg-danger-subtle" title="Hapus Jenis Kendaraan">
      <p class="mb-2">Yakin ingin menghapus <strong>{{ deletingType?.name }}</strong>?</p>
      <p class="text-muted small">Data yang sudah dipakai tarif atau sesi parkir akan ditolak oleh server agar histori tetap aman.</p>
      <div class="d-flex justify-content-end gap-2 mt-4">
        <BButton id="vehicle-type-delete-cancel" variant="light" @click="deleteModalOpen = false">Batal</BButton>
        <BButton id="vehicle-type-delete-confirm" variant="danger" @click="destroyType">Hapus</BButton>
      </div>
    </BModal>
  </Layout>
</template>

<style scoped>
.vehicle-hero {
  background: radial-gradient(circle at top right, rgba(255,255,255,.32), transparent 28%), linear-gradient(135deg, #10b981, #0891b2 52%, #4f46e5);
  box-shadow: 0 22px 55px rgba(8, 145, 178, .24);
}
.vehicle-hero-icon {
  width: 56px;
  height: 56px;
  border-radius: 18px;
  display: grid;
  place-items: center;
  background: rgba(255,255,255,.2);
  backdrop-filter: blur(8px);
  font-size: 28px;
}
.vehicle-icon {
  width: 42px;
  height: 42px;
  border-radius: 14px;
  display: grid;
  place-items: center;
  color: #0ab39c;
  background: linear-gradient(135deg, rgba(10,179,156,.14), rgba(64,81,137,.1));
  font-size: 20px;
}
.stat-card,
.master-card {
  transition: transform .2s ease, box-shadow .2s ease;
}
.stat-card:hover,
.master-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 18px 45px rgba(15, 23, 42, .10) !important;
}
.text-white-75 { color: rgba(255,255,255,.76); }
</style>
