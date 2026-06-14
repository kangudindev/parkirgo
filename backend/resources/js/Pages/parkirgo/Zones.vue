<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { router } from "@inertiajs/vue3";

export default {
  components: { Layout, PageHeader },
  props: {
    zones: { type: Array, default: () => [] },
    tariffs: { type: Array, default: () => [] },
    vehicleTypes: { type: Array, default: () => [] },
  },
  data() {
    return {
      showZoneModal: false,
      showTariffModal: false,
      editingZone: null,
      editingTariff: null,
      zoneForm: { code: '', name: '', city: '', capacities: [], qris_payload: '', status: 'active' },
      tariffForm: { zone_id: null, vehicle_type_id: null, pricing_type: 'flat', payment_timing: 'entry', base_minutes: 60, base_rate: 0, increment_minutes: 60, increment_rate: 0, daily_max_rate: 0, grace_period_minutes: 15, rounding_minutes: 0 },
    };
  },
  computed: {
    activeVehicleTypes() {
      return this.vehicleTypes.filter(vt => vt.status === 'active');
    },
  },
  methods: {
    initCapacities() {
      const existing = this.editingZone
        ? (this.editingZone.vehicle_types || []).reduce((map, vt) => {
            map[vt.id] = vt.pivot.capacity;
            return map;
          }, {})
        : {};
      this.zoneForm.capacities = this.activeVehicleTypes.map(vt => ({
        vehicle_type_id: vt.id,
        capacity: existing[vt.id] || 0,
      }));
    },
    openZone(z) {
      if (z) {
        this.editingZone = z;
        this.zoneForm = { code: z.code, name: z.name, city: z.city || '', capacities: [], qris_payload: z.qris_payload || '', status: z.status };
      } else {
        this.editingZone = null;
        this.zoneForm = { code: '', name: '', city: '', capacities: [], qris_payload: '', status: 'active' };
      }
      this.initCapacities();
      this.showZoneModal = true;
    },
    saveZone() {
      if (!this.zoneForm.code || !this.zoneForm.name) {
        this.$page.props.flash = { error: 'Kode dan Nama zona harus diisi.' };
        return;
      }
      const payload = { ...this.zoneForm, capacities: this.zoneForm.capacities.filter(c => c.capacity > 0) };
      if (this.editingZone) {
        router.post(route('parkirgo.zones.update', this.editingZone.id), payload, { preserveScroll: true, onSuccess: () => this.showZoneModal = false });
      } else {
        router.post(route('parkirgo.zones.store'), payload, { preserveScroll: true, onSuccess: () => this.showZoneModal = false });
      }
    },
    deleteZone(z) {
      if (!confirm(`Hapus zona ${z.name}?`)) return;
      router.delete(route('parkirgo.zones.destroy', z.id), { preserveScroll: true });
    },
    capForZone(zone, vtId) {
      const vt = (zone.vehicle_types || []).find(v => v.id === vtId);
      return vt ? vt.pivot.capacity : '-';
    },
    openTariff(t) {
      this.editingTariff = t;
      if (t) this.tariffForm = { zone_id: t.zone_id, vehicle_type_id: t.vehicle_type_id, pricing_type: t.pricing_type, payment_timing: t.payment_timing, base_minutes: t.base_minutes, base_rate: t.base_rate, increment_minutes: t.increment_minutes, increment_rate: t.increment_rate, daily_max_rate: t.daily_max_rate, grace_period_minutes: t.grace_period_minutes, rounding_minutes: t.rounding_minutes };
      else this.tariffForm = { zone_id: this.zones[0]?.id || null, vehicle_type_id: null, pricing_type: 'flat', payment_timing: 'entry', base_minutes: 60, base_rate: 0, increment_minutes: 60, increment_rate: 0, daily_max_rate: 0, grace_period_minutes: 15, rounding_minutes: 0 };
      this.showTariffModal = true;
    },
    saveTariff() {
      if (!this.tariffForm.zone_id || !this.tariffForm.vehicle_type_id || !this.tariffForm.base_rate) {
        this.$page.props.flash = { error: 'Zona, Jenis Kendaraan, dan Tarif Dasar harus diisi.' };
        return;
      }
      if (this.editingTariff) router.put(route('parkirgo.tariffs.update', this.editingTariff.id), this.tariffForm, { preserveScroll: true, onSuccess: () => this.showTariffModal = false });
      else router.post(route('parkirgo.tariffs.store'), this.tariffForm, { preserveScroll: true, onSuccess: () => this.showTariffModal = false });
    },
    deleteTariff(t) {
      if (!confirm('Hapus tarif ini?')) return;
      router.delete(route('parkirgo.tariffs.destroy', t.id), { preserveScroll: true });
    },
    vtName(id) {
      const vt = this.vehicleTypes.find(v => v.id === id);
      return vt ? vt.name : '-';
    },
    typeLabel(t) { return t === 'flat' ? 'Flat' : 'Progresif'; },
    timingLabel(t) { return t === 'entry' ? 'Bayar Masuk' : 'Bayar Keluar'; },
    formatRp(v) { return 'Rp ' + Number(v).toLocaleString('id-ID'); },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Zona & Tarif" pageTitle="ParkirGo" />

    <BCard no-body class="border-0 shadow-sm mb-4">
      <BCardHeader class="d-flex align-items-center justify-content-between">
        <BCardTitle class="mb-0">Daftar Zona</BCardTitle>
        <BButton variant="primary" @click="openZone(null)">
          <i class="ri-add-line me-1"></i>Tambah Zona
        </BButton>
      </BCardHeader>
      <BCardBody>
        <BRow>
          <BCol v-for="z in zones" :key="z.id" md="4" class="mb-3">
            <BCard no-body class="h-100">
              <BCardBody>
                <div class="d-flex justify-content-between align-items-start">
                  <div>
                    <h5 class="mb-1">{{ z.name }}</h5>
                    <span class="badge bg-primary-subtle text-primary">{{ z.code }}</span>
                    <span v-if="z.city" class="ms-1 text-muted small">{{ z.city }}</span>
                  </div>
                  <div class="d-flex gap-1">
                    <BButton size="sm" variant="outline-secondary" @click="openZone(z)"><i class="ri-pencil-line"></i></BButton>
                    <BButton size="sm" variant="outline-danger" @click="deleteZone(z)"><i class="ri-delete-bin-line"></i></BButton>
                  </div>
                </div>
                <hr />
                <div class="d-flex gap-3 text-center flex-wrap">
                  <div v-for="vt in activeVehicleTypes" :key="vt.id">
                    <small class="text-muted">{{ vt.name }}</small><br />
                    <strong>{{ capForZone(z, vt.id) }}</strong>
                  </div>
                  <div><small class="text-muted">Jukir</small><br /><strong>{{ z.jukirs_count || 0 }}</strong></div>
                </div>
              </BCardBody>
            </BCard>
          </BCol>
        </BRow>
      </BCardBody>
    </BCard>

    <!-- Tariff Matrix -->
    <BCard no-body class="border-0 shadow-sm">
      <BCardHeader class="d-flex align-items-center justify-content-between">
        <BCardTitle class="mb-0">Matriks Tarif</BCardTitle>
        <BButton variant="outline-primary" @click="openTariff(null)">
          <i class="ri-add-line me-1"></i>Tambah Tarif
        </BButton>
      </BCardHeader>
      <BCardBody>
        <div class="table-responsive">
          <table class="table table-hover">
            <thead class="table-light">
              <tr>
                <th>Zona</th>
                <th>Kendaraan</th>
                <th>Tipe</th>
                <th>Bayar</th>
                <th>Tarif Dasar</th>
                <th>Increment</th>
                <th>Max Harian</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="t in tariffs" :key="t.id">
                <td>{{ t.zone?.name || '-' }}</td>
                <td>{{ t.vehicle_type_master?.name || vtName(t.vehicle_type_id) || '-' }}</td>
                <td><span class="badge bg-info-subtle text-info">{{ typeLabel(t.pricing_type) }}</span></td>
                <td>{{ timingLabel(t.payment_timing) }}</td>
                <td>{{ formatRp(t.base_rate) }}{{ t.base_minutes ? '/'+t.base_minutes+'m' : '' }}</td>
                <td>{{ t.increment_rate ? formatRp(t.increment_rate)+'/'+t.increment_minutes+'m' : '-' }}</td>
                <td>{{ t.daily_max_rate ? formatRp(t.daily_max_rate) : '-' }}</td>
                <td class="d-flex gap-1">
                  <BButton size="sm" variant="outline-secondary" @click="openTariff(t)"><i class="ri-pencil-line"></i></BButton>
                  <BButton size="sm" variant="outline-danger" @click="deleteTariff(t)"><i class="ri-delete-bin-line"></i></BButton>
                </td>
              </tr>
              <tr v-if="!tariffs.length"><td colspan="8" class="text-center text-muted">Belum ada tarif.</td></tr>
            </tbody>
          </table>
        </div>
      </BCardBody>
    </BCard>

    <!-- Zone Modal -->
    <BModal v-model="showZoneModal" :title="editingZone ? 'Edit Zona' : 'Tambah Zona'" hide-footer>
      <div class="mb-2"><label class="form-label">Kode Zona</label><input v-model="zoneForm.code" class="form-control" maxlength="3" /></div>
      <div class="mb-2"><label class="form-label">Nama Zona</label><input v-model="zoneForm.name" class="form-control" /></div>
      <div class="mb-2"><label class="form-label">Kota</label><input v-model="zoneForm.city" class="form-control" /></div>
      <div class="mb-2">
        <label class="form-label">Kapasitas per Jenis Kendaraan</label>
        <div v-for="vt in activeVehicleTypes" :key="vt.id" class="d-flex align-items-center gap-2 mb-1">
          <span class="small" style="min-width:100px">{{ vt.name }}</span>
          <input type="number" min="0" class="form-control form-control-sm"
            :value="(zoneForm.capacities.find(c => c.vehicle_type_id === vt.id) || {}).capacity || 0"
            @input="e => { const entry = zoneForm.capacities.find(c => c.vehicle_type_id === vt.id); if (entry) entry.capacity = parseInt(e.target.value) || 0; else zoneForm.capacities.push({ vehicle_type_id: vt.id, capacity: parseInt(e.target.value) || 0 }); }" />
        </div>
      </div>
      <div class="mb-2"><label class="form-label">QRIS Payload</label><textarea v-model="zoneForm.qris_payload" class="form-control" rows="2"></textarea></div>
      <div class="mb-3"><label class="form-label">Status</label><select v-model="zoneForm.status" class="form-select"><option value="active">Aktif</option><option value="inactive">Nonaktif</option></select></div>
      <div class="d-flex justify-content-end gap-2">
        <BButton variant="light" @click="showZoneModal=false">Batal</BButton>
        <BButton variant="primary" @click="saveZone">Simpan</BButton>
      </div>
    </BModal>

    <!-- Tariff Modal -->
    <BModal v-model="showTariffModal" :title="editingTariff ? 'Edit Tarif' : 'Tambah Tarif'" hide-footer>
      <div class="mb-2"><label class="form-label">Zona</label><select v-model="tariffForm.zone_id" class="form-select"><option v-for="z in zones" :key="z.id" :value="z.id">{{ z.name }}</option></select></div>
      <div class="mb-2"><label class="form-label">Jenis Kendaraan</label><select v-model="tariffForm.vehicle_type_id" class="form-select"><option value="">-- Pilih --</option><option v-for="vt in vehicleTypes" :key="vt.id" :value="vt.id">{{ vt.name }}</option></select></div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">Tipe</label><select v-model="tariffForm.pricing_type" class="form-select"><option value="flat">Flat</option><option value="progressive">Progresif</option></select></div>
        <div class="col-6"><label class="form-label">Bayar</label><select v-model="tariffForm.payment_timing" class="form-select"><option value="entry">Masuk</option><option value="exit">Keluar</option></select></div>
      </div>
      <div class="row mb-2">
        <div class="col-4"><label class="form-label">Base Rate</label><input v-model.number="tariffForm.base_rate" type="number" class="form-control" /></div>
        <div class="col-4"><label class="form-label">Base Menit</label><input v-model.number="tariffForm.base_minutes" type="number" class="form-control" /></div>
        <div class="col-4"><label class="form-label">Max Harian</label><input v-model.number="tariffForm.daily_max_rate" type="number" class="form-control" /></div>
      </div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">Increment Rate</label><input v-model.number="tariffForm.increment_rate" type="number" class="form-control" /></div>
        <div class="col-6"><label class="form-label">Increment Menit</label><input v-model.number="tariffForm.increment_minutes" type="number" class="form-control" /></div>
      </div>
      <div class="mb-3"><label class="form-label">Grace Period (menit)</label><input v-model.number="tariffForm.grace_period_minutes" type="number" class="form-control" /></div>
      <div class="d-flex justify-content-end gap-2">
        <BButton variant="light" @click="showTariffModal=false">Batal</BButton>
        <BButton variant="primary" @click="saveTariff">Simpan</BButton>
      </div>
    </BModal>
  </Layout>
</template>

