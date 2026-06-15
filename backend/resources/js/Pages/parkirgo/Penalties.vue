<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { router } from "@inertiajs/vue3";
import Swal from "sweetalert2";

export default {
  components: { Layout, PageHeader },
  props: {
    penalties: { type: Array, default: () => [] },
    zones: { type: Array, default: () => [] },
    vehicleTypes: { type: Array, default: () => [] },
  },
  data() {
    return {
      showModal: false,
      editing: null,
      form: {
        zone_id: null,
        vehicle_type: null,
        penalty_type: 'card_lost',
        amount: 0,
      },
    };
  },
  computed: {
    groupedPenalties() {
      const groups = {};
      for (const p of this.penalties) {
        const key = p.zone?.id || p.zone_id;
        if (!groups[key]) {
          groups[key] = {
            zone: this.zones.find(z => z.id === key) || p.zone,
            card_lost: {},
            unregistered: {},
          };
        }
        const vt = p.vehicle_type || 'semua';
        groups[key][p.penalty_type][vt] = p;
      }
      return Object.values(groups);
    },
    selectedZoneVehicleTypes() {
      if (!this.form.zone_id) return this.vehicleTypes;
      const zone = this.zones.find(z => z.id === this.form.zone_id);
      return zone && zone.vehicle_types && zone.vehicle_types.length > 0 ? zone.vehicle_types : this.vehicleTypes;
    }
  },
  methods: {
    openAdd() {
      this.editing = null;
      this.form = { zone_id: null, vehicle_type: null, penalty_type: 'card_lost', amount: 0 };
      this.showModal = true;
    },
    openEdit(p) {
      this.editing = p;
      this.form = {
        zone_id: p.zone_id,
        vehicle_type: p.vehicle_type,
        penalty_type: p.penalty_type,
        amount: p.amount,
      };
      this.showModal = true;
    },
    save() {
      if (!this.form.zone_id || !this.form.amount) {
        this.$page.props.flash = { error: 'Zona dan nominal denda harus diisi.' };
        return;
      }
      if (this.form.amount < 0) {
        this.$page.props.flash = { error: 'Nominal denda tidak boleh negatif.' };
        return;
      }
      if (this.editing) {
        router.put(route('parkirgo.penalties.update', this.editing.id), this.form, {
          preserveScroll: true,
          onSuccess: () => { this.showModal = false; },
        });
      } else {
        router.post(route('parkirgo.penalties.store'), this.form, {
          preserveScroll: true,
          onSuccess: () => { this.showModal = false; },
        });
      }
    },
    remove(p) {
      Swal.fire({
        title: "Hapus Denda?",
        text: `Yakin ingin menghapus denda ${this.typeLabel(p.penalty_type)}?`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#f06548",
        confirmButtonText: "Ya, Hapus",
        cancelButtonText: "Batal",
      }).then((r) => { if (r.isConfirmed) router.delete(route('parkirgo.penalties.destroy', p.id), { preserveScroll: true }); });
    },
    typeLabel(t) {
      return t === 'card_lost' ? 'Karcis Hilang' : 'Tidak Tercatat';
    },
    formatRp(v) {
      return 'Rp ' + Number(v).toLocaleString('id-ID');
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Manajemen Denda" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total Konfigurasi Denda</p>
                <h3 class="mb-0">{{ penalties.length }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-danger-subtle text-danger d-flex align-items-center justify-content-center">
                <i class="ri-alert-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BCard no-body class="border-0 shadow-sm">
      <BCardHeader class="d-flex align-items-center justify-content-between">
        <div>
          <BCardTitle class="mb-1">Denda per Zona</BCardTitle>
          <p class="text-muted mb-0">Konfigurasi denda karcis hilang & kendaraan tidak tercatat.</p>
        </div>
        <BButton variant="primary" @click="openAdd">
          <i class="ri-add-line me-1"></i>Tambah Denda
        </BButton>
      </BCardHeader>
      <BCardBody>
        <div v-if="!groupedPenalties.length" class="text-center text-muted py-4">
          Belum ada konfigurasi denda. Klik "Tambah Denda" untuk memulai.
        </div>

        <div v-for="group in groupedPenalties" :key="group.zone?.id || 0" class="mb-5">
          <h5 class="mb-3 fw-bold border-bottom pb-2">{{ group.zone?.name || 'Zona' }} <span class="text-muted small fw-normal ms-1">({{ group.zone?.code || '-' }})</span></h5>
          
          <BRow class="g-3">
            <BCol md="6" v-for="type in ['card_lost', 'unregistered']" :key="type">
              <BCard no-body class="border shadow-none h-100 mb-0">
                <BCardHeader class="bg-light py-2">
                  <h6 class="mb-0">{{ typeLabel(type) }}</h6>
                </BCardHeader>
                <BCardBody class="p-3">
                  <div class="d-flex flex-column gap-2">
                    <!-- Loop actual vehicle types available in this zone -->
                    <div v-for="vt in (group.zone?.vehicle_types || vehicleTypes)" :key="vt.code" class="d-flex align-items-center justify-content-between p-2 rounded bg-body-tertiary">
                      <div class="d-flex align-items-center gap-2">
                        <i :class="vt.icon" class="text-primary"></i>
                        <span>{{ vt.name }}</span>
                      </div>
                      
                      <div v-if="group[type][vt.code]" class="d-flex align-items-center gap-2">
                        <span class="fw-semibold">{{ formatRp(group[type][vt.code].amount) }}</span>
                        <div class="d-flex gap-1">
                          <button class="btn btn-sm btn-soft-secondary py-0 px-1" @click="openEdit(group[type][vt.code])" title="Edit"><i class="ri-pencil-line"></i></button>
                          <button class="btn btn-sm btn-soft-danger py-0 px-1" @click="remove(group[type][vt.code])" title="Hapus"><i class="ri-delete-bin-line"></i></button>
                        </div>
                      </div>
                      <span v-else class="text-muted small fst-italic">Belum diatur</span>
                    </div>

                    <!-- Fallback / Semua Jenis -->
                    <div class="d-flex align-items-center justify-content-between p-2 rounded border border-warning-subtle">
                      <div class="d-flex align-items-center gap-2">
                        <i class="ri-asterisk text-warning"></i>
                        <span class="text-warning fw-medium">Semua Jenis / Fallback</span>
                      </div>
                      
                      <div v-if="group[type]['semua']" class="d-flex align-items-center gap-2">
                        <span class="fw-semibold text-warning">{{ formatRp(group[type]['semua'].amount) }}</span>
                        <div class="d-flex gap-1">
                          <button class="btn btn-sm btn-soft-secondary py-0 px-1" @click="openEdit(group[type]['semua'])" title="Edit"><i class="ri-pencil-line"></i></button>
                          <button class="btn btn-sm btn-soft-danger py-0 px-1" @click="remove(group[type]['semua'])" title="Hapus"><i class="ri-delete-bin-line"></i></button>
                        </div>
                      </div>
                      <span v-else class="text-muted small fst-italic">Belum diatur</span>
                    </div>
                  </div>
                </BCardBody>
              </BCard>
            </BCol>
          </BRow>
        </div>
      </BCardBody>
    </BCard>

    <!-- Modal -->
    <BModal v-model="showModal" title="Tambah / Edit Denda" hide-footer>
      <div class="mb-3">
        <label class="form-label">Zona</label>
        <select v-model="form.zone_id" class="form-select">
          <option :value="null" disabled>Pilih Zona...</option>
          <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.name }} ({{ z.code }})</option>
        </select>
      </div>
      <div class="mb-3">
        <label class="form-label">Jenis Kendaraan</label>
        <select v-model="form.vehicle_type" class="form-select" :disabled="!form.zone_id">
          <option :value="null">Semua Jenis (Fallback)</option>
          <option v-for="vt in selectedZoneVehicleTypes" :key="vt.code" :value="vt.code">{{ vt.name }}</option>
        </select>
        <div v-if="!form.zone_id" class="form-text text-warning">Pilih zona terlebih dahulu untuk melihat jenis kendaraan yang sesuai.</div>
      </div>
      <div class="mb-3">
        <label class="form-label">Tipe Denda</label>
        <select v-model="form.penalty_type" class="form-select">
          <option value="card_lost">Karcis Hilang</option>
          <option value="unregistered">Tidak Tercatat</option>
        </select>
      </div>
      <div class="mb-3">
        <label class="form-label">Nominal Denda (Rp)</label>
        <input v-model.number="form.amount" type="number" class="form-control" min="0" />
      </div>
      <div class="d-flex justify-content-end gap-2">
        <BButton variant="light" @click="showModal = false">Batal</BButton>
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
