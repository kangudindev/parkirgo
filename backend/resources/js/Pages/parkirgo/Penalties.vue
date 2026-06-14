<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { router } from "@inertiajs/vue3";

export default {
  components: { Layout, PageHeader },
  props: {
    penalties: { type: Array, default: () => [] },
    zones: { type: Array, default: () => [] },
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
            zone: p.zone,
            card_lost: {},
            unregistered: {},
          };
        }
        const vt = p.vehicle_type || 'semua';
        groups[key][p.penalty_type][vt] = p;
      }
      return Object.values(groups);
    },
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
      if (!confirm(`Hapus denda ${p.penalty_type} untuk ${p.zone?.name || 'zona'}?`)) return;
      router.delete(route('parkirgo.penalties.destroy', p.id), { preserveScroll: true });
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

        <div v-for="group in groupedPenalties" :key="group.zone?.id || 0" class="mb-4">
          <h5 class="mb-2">{{ group.zone?.name || 'Zona' }} ({{ group.zone?.code || '-' }})</h5>
          <div class="table-responsive">
            <table class="table table-hover table-bordered align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th style="width:140px">Tipe Denda</th>
                  <th>Motor</th>
                  <th>Mobil</th>
                  <th>Bus/Truk</th>
                  <th>Semua Jenis</th>
                  <th style="width:100px">Aksi</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="type in ['card_lost', 'unregistered']" :key="type">
                  <td>{{ typeLabel(type) }}</td>
                  <td v-for="vt in ['motor', 'mobil', 'bus', 'truk']" :key="vt">
                    <span v-if="group[type][vt]" class="fw-semibold">
                      {{ formatRp(group[type][vt].amount) }}
                    </span>
                    <span v-else class="text-muted">-</span>
                  </td>
                  <td>
                    <div v-if="group[type]['semua']" class="d-flex align-items-center gap-1">
                      <span class="fw-semibold text-warning">{{ formatRp(group[type]['semua'].amount) }}</span>
                      <span class="badge bg-warning-subtle text-warning" style="font-size:10px">fallback</span>
                    </div>
                    <span v-else class="text-muted">-</span>
                  </td>
                  <td>
                    <div class="d-flex gap-1">
                      <BButton v-for="(p) in [group[type]['motor'], group[type]['mobil'], group[type]['bus'], group[type]['truk'], group[type]['semua']].filter(Boolean)" :key="p.id"
                        size="sm" variant="outline-secondary" @click="openEdit(p)">
                        <i class="ri-pencil-line"></i>
                      </BButton>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </BCardBody>
    </BCard>

    <!-- Modal -->
    <BModal v-model="showModal" title="Tambah / Edit Denda" hide-footer>
      <div class="mb-3">
        <label class="form-label">Zona</label>
        <select v-model="form.zone_id" class="form-select">
          <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.name }} ({{ z.code }})</option>
        </select>
      </div>
      <div class="mb-3">
        <label class="form-label">Jenis Kendaraan</label>
        <select v-model="form.vehicle_type" class="form-select">
          <option value="">Semua Jenis</option>
          <option value="motor">Motor</option>
          <option value="mobil">Mobil</option>
          <option value="bus">Bus</option>
          <option value="truk">Truk</option>
        </select>
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
