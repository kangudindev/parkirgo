<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import DataTable from "@/Components/DataTable.vue";
import { router } from "@inertiajs/vue3";

export default {
  components: { Layout, PageHeader, DataTable },
  props: {
    zones: { type: Object, default: () => ({ data: [] }) },
    tariffs: { type: Array, default: () => [] },
    vehicleTypes: { type: Array, default: () => [] },
    sortField: { type: String, default: "created_at" },
    sortDir: { type: String, default: "desc" },
  },
  data() {
    return {
      showZoneModal: false,
      showTariffModal: false,
      editingZone: null,
      editingTariff: null,
      zoneForm: { code: "", name: "", city: "", capacities: [], qris_payload: "", status: "active" },
      tariffForm: { zone_id: null, vehicle_type_id: null, pricing_type: "flat", payment_timing: "entry", base_minutes: 60, base_rate: 0, increment_minutes: 60, increment_rate: 0, daily_max_rate: 0, grace_period_minutes: 15, rounding_minutes: 0 },
      searchQuery: "",
      perPageVal: 15,
      tableSortField: this.sortField,
      tableSortDir: this.sortDir,
      searchQuery: "",
      perPageVal: 15,
      selectedVehicleTypeId: null,
    };
  },
  computed: {
    activeVehicleTypes() {
      return this.vehicleTypes.filter(vt => vt.status === "active");
    },
    availableVehicleTypes() {
      const usedIds = this.zoneForm.capacities.map(c => c.vehicle_type_id);
      return this.activeVehicleTypes.filter(vt => !usedIds.includes(vt.id));
    },
    zoneVehicleTypes() {
      if (!this.tariffForm.zone_id) return [];
      const zone = this.zones.data?.find(z => z.id === this.tariffForm.zone_id)
        || this.zones.find(z => z.id === this.tariffForm.zone_id);
      if (!zone) return [];
      return this.tariffForm.zone_id
        ? this.vehicleTypes.filter(vt => (zone.vehicle_types || []).some(zvt => zvt.id === vt.id && (zvt.pivot?.capacity || 0) > 0))
        : [];
    },
    columns() {
      return [
        { key: "name", label: "Zona" },
        { key: "code", label: "Kode", width: "100px" },
        { key: "city", label: "Kota" },
        { key: "jukirs_count", label: "Jukir", width: "70px" },
        { key: "status", label: "Status", width: "100px" },
        { key: "actions", label: "Aksi", sortable: false, width: "100px" },
      ];
    },
    tariffColumns() {
      return [
        { key: "zone_name", label: "Zona" },
        { key: "vehicle", label: "Kendaraan" },
        { key: "pricing_type", label: "Tipe Tarif", width: "110px" },
        { key: "payment_timing", label: "Waktu Bayar", width: "110px" },
        { key: "base_rate", label: "Tarif Dasar", width: "150px" },
        { key: "increment", label: "Tambahan", width: "150px" },
        { key: "daily_max_rate", label: "Maks Harian", width: "120px" },
        { key: "actions", label: "Aksi", sortable: false, width: "100px" },
      ];
    },
  },
  methods: {
    initCapacities() {
      const existing = this.editingZone
        ? (this.editingZone.vehicle_types || []).filter(vt => (vt.pivot?.capacity || 0) > 0).map(vt => ({ vehicle_type_id: vt.id, capacity: vt.pivot.capacity }))
        : [];
      this.zoneForm.capacities = [...existing];
    },
    openZone(z) {
      if (z) {
        this.editingZone = z;
        this.zoneForm = { code: z.code, name: z.name, city: z.city || "", capacities: [], qris_payload: z.qris_payload || "", status: z.status };
      } else {
        this.editingZone = null;
        this.zoneForm = { code: "", name: "", city: "", capacities: [], qris_payload: "", status: "active" };
      }
      this.initCapacities();
      this.selectedVehicleTypeId = null;
      this.showZoneModal = true;
    },
    addCapacity() {
      if (!this.selectedVehicleTypeId) return;
      this.zoneForm.capacities.push({ vehicle_type_id: this.selectedVehicleTypeId, capacity: 0 });
      this.selectedVehicleTypeId = null;
    },
    removeCapacity(index) {
      this.zoneForm.capacities.splice(index, 1);
    },
    saveZone() {
      if (!this.zoneForm.code || !this.zoneForm.name) {
        this.$page.props.flash = { error: "Kode dan Nama zona harus diisi." };
        return;
      }
      const payload = { ...this.zoneForm, capacities: this.zoneForm.capacities.filter(c => c.capacity > 0) };
      if (this.editingZone) {
        router.post(route("parkirgo.zones.update", this.editingZone.id), payload, { preserveScroll: true, onSuccess: () => this.showZoneModal = false });
      } else {
        router.post(route("parkirgo.zones.store"), payload, { preserveScroll: true, onSuccess: () => this.showZoneModal = false });
      }
    },
    deleteZone(z) {
      if (!confirm(`Hapus zona ${z.name}?`)) return;
      router.delete(route("parkirgo.zones.destroy", z.id), { preserveScroll: true });
    },
    capForZone(zone, vtId) {
      const vt = (zone.vehicle_types || []).find(v => v.id === vtId);
      return vt ? vt.pivot.capacity : 0;
    },
    zoneHasVt(zone, vtId) {
      return this.capForZone(zone, vtId) > 0;
    },
    openTariff(t) {
      this.editingTariff = t;
      if (t) {
        this.tariffForm = { zone_id: t.zone_id, vehicle_type_id: t.vehicle_type_id, pricing_type: t.pricing_type, payment_timing: t.payment_timing, base_minutes: t.base_minutes, base_rate: t.base_rate, increment_minutes: t.increment_minutes, increment_rate: t.increment_rate, daily_max_rate: t.daily_max_rate, grace_period_minutes: t.grace_period_minutes, rounding_minutes: t.rounding_minutes };
      } else {
        const firstZone = this.zones.data?.[0] || this.zones[0];
        this.tariffForm = { zone_id: firstZone?.id || null, vehicle_type_id: null, pricing_type: "flat", payment_timing: "entry", base_minutes: 60, base_rate: 0, increment_minutes: 60, increment_rate: 0, daily_max_rate: 0, grace_period_minutes: 15, rounding_minutes: 0 };
      }
      this.showTariffModal = true;
    },
    saveTariff() {
      if (!this.tariffForm.zone_id || !this.tariffForm.vehicle_type_id || !this.tariffForm.base_rate) {
        this.$page.props.flash = { error: "Zona, Jenis Kendaraan, dan Tarif Dasar harus diisi." };
        return;
      }
      if (this.editingTariff) router.put(route("parkirgo.tariffs.update", this.editingTariff.id), this.tariffForm, { preserveScroll: true, onSuccess: () => this.showTariffModal = false });
      else router.post(route("parkirgo.tariffs.store"), this.tariffForm, { preserveScroll: true, onSuccess: () => this.showTariffModal = false });
    },
    deleteTariff(t) {
      if (!confirm("Hapus tarif ini?")) return;
      router.delete(route("parkirgo.tariffs.destroy", t.id), { preserveScroll: true });
    },
    vtName(id) {
      const vt = this.vehicleTypes.find(v => v.id === id);
      return vt ? vt.name : "-";
    },
    typeLabel(t) { return t === "flat" ? "Flat" : "Progresif"; },
    timingLabel(t) { return t === "entry" ? "Bayar Masuk" : "Bayar Keluar"; },
    formatRp(v) { return "Rp " + Number(v).toLocaleString("id-ID"); },
    onSort(field, dir) {
      this.tableSortField = field;
      this.tableSortDir = dir;
      router.get("/parkirgo/zones", { sort_field: field, sort_dir: dir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onSearch(q) {
      this.searchQuery = q;
      router.get("/parkirgo/zones", { search: q, sort_field: this.tableSortField, sort_dir: this.tableSortDir, per_page: this.perPageVal }, { preserveState: true });
    },
    onPage(page) {
      router.get("/parkirgo/zones", { page, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery, per_page: this.perPageVal }, { preserveState: true });
    },
    onPerPage(val) {
      this.perPageVal = val;
      router.get("/parkirgo/zones", { per_page: val, sort_field: this.tableSortField, sort_dir: this.tableSortDir, search: this.searchQuery }, { preserveState: true });
    },
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
        <DataTable
          :columns="columns"
          :data="zones"
          :sort-field="tableSortField"
          :sort-dir="tableSortDir"
          @sort="onSort"
          @search="onSearch"
          @page-change="onPage"
          @per-page-change="onPerPage"
        >
          <template #cell-city="{ row }">{{ row.city || "-" }}</template>
          <template #cell-status="{ row }">
            <span class="badge bg-success-subtle text-success">{{ row.status }}</span>
          </template>
          <template #cell-actions="{ row }">
            <div class="d-flex gap-1">
              <BButton size="sm" variant="outline-secondary" @click="openZone(row)"><i class="ri-pencil-line"></i></BButton>
              <BButton size="sm" variant="outline-danger" @click="deleteZone(row)"><i class="ri-delete-bin-line"></i></BButton>
            </div>
          </template>
        </DataTable>
      </BCardBody>
    </BCard>

    <BCard no-body class="border-0 shadow-sm mb-4">
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
                <th>Tipe Tarif</th>
                <th>Waktu Bayar</th>
                <th>Tarif Dasar</th>
                <th>Tambahan</th>
                <th>Maks Harian</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="t in tariffs" :key="t.id">
                <td>{{ t.zone?.name || "-" }}</td>
                <td>{{ t.vehicle_type_master?.name || vtName(t.vehicle_type_id) || "-" }}</td>
                <td><span class="badge bg-info-subtle text-info">{{ typeLabel(t.pricing_type) }}</span></td>
                <td>{{ timingLabel(t.payment_timing) }}</td>
                <td>{{ formatRp(t.base_rate) }}{{ t.base_minutes ? "/"+t.base_minutes+"m" : "" }}</td>
                <td>{{ t.increment_rate ? formatRp(t.increment_rate)+"/"+t.increment_minutes+"m" : "-" }}</td>
                <td>{{ t.daily_max_rate ? formatRp(t.daily_max_rate) : "-" }}</td>
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

    <BModal v-model="showZoneModal" :title="editingZone ? 'Edit Zona' : 'Tambah Zona'" hide-footer>
      <div class="mb-2"><label class="form-label">Kode Zona</label><input v-model="zoneForm.code" class="form-control" maxlength="3" /></div>
      <div class="mb-2"><label class="form-label">Nama Zona</label><input v-model="zoneForm.name" class="form-control" /></div>
      <div class="mb-2"><label class="form-label">Kota</label><input v-model="zoneForm.city" class="form-control" /></div>

      <div class="mb-2">
        <label class="form-label">Kapasitas Kendaraan</label>
        <div v-for="(cap, i) in zoneForm.capacities" :key="i" class="d-flex align-items-center gap-2 mb-1">
          <span class="small fw-medium" style="min-width:100px">{{ vtName(cap.vehicle_type_id) }}</span>
          <input type="number" min="0" class="form-control form-control-sm" v-model.number="cap.capacity" />
          <BButton size="sm" variant="outline-danger" @click="removeCapacity(i)"><i class="ri-close-line"></i></BButton>
        </div>
        <div v-if="availableVehicleTypes.length" class="d-flex align-items-center gap-2 mt-1">
          <select v-model="selectedVehicleTypeId" class="form-select form-select-sm" style="max-width:200px">
            <option value="">-- Pilih Kendaraan --</option>
            <option v-for="vt in availableVehicleTypes" :key="vt.id" :value="vt.id">{{ vt.name }}</option>
          </select>
          <BButton size="sm" variant="outline-primary" @click="addCapacity">
            <i class="ri-add-line"></i>Tambah
          </BButton>
        </div>
        <small v-if="!availableVehicleTypes.length && zoneForm.capacities.length" class="text-muted">Semua kendaraan sudah ditambahkan.</small>
      </div>

      <div class="mb-2"><label class="form-label">QRIS Payload</label><textarea v-model="zoneForm.qris_payload" class="form-control" rows="2"></textarea></div>
      <div class="mb-3"><label class="form-label">Status</label><select v-model="zoneForm.status" class="form-select"><option value="active">Aktif</option><option value="inactive">Nonaktif</option></select></div>
      <div class="d-flex justify-content-end gap-2">
        <BButton variant="light" @click="showZoneModal=false">Batal</BButton>
        <BButton variant="primary" @click="saveZone">Simpan</BButton>
      </div>
    </BModal>

    <BModal v-model="showTariffModal" :title="editingTariff ? 'Edit Tarif' : 'Tambah Tarif'" hide-footer>
      <div class="mb-2"><label class="form-label">Zona</label><select v-model="tariffForm.zone_id" class="form-select"><option v-for="z in zones.data || zones" :key="z.id" :value="z.id">{{ z.name }}</option></select></div>
      <div class="mb-2"><label class="form-label">Jenis Kendaraan</label>
        <select v-model="tariffForm.vehicle_type_id" class="form-select">
          <option value="">-- Pilih --</option>
          <option v-for="vt in zoneVehicleTypes" :key="vt.id" :value="vt.id">{{ vt.name }}</option>
        </select>
      </div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">Tipe Tarif</label><select v-model="tariffForm.pricing_type" class="form-select"><option value="flat">Flat</option><option value="progressive">Progresif</option></select></div>
        <div class="col-6"><label class="form-label">Waktu Bayar</label><select v-model="tariffForm.payment_timing" class="form-select"><option value="entry">Masuk</option><option value="exit">Keluar</option></select></div>
      </div>
      <div class="row mb-2">
        <div class="col-4"><label class="form-label">Tarif Dasar</label><input v-model.number="tariffForm.base_rate" type="number" class="form-control" /></div>
        <div class="col-4"><label class="form-label">Menit Dasar</label><input v-model.number="tariffForm.base_minutes" type="number" class="form-control" /></div>
        <div class="col-4"><label class="form-label">Maks Harian</label><input v-model.number="tariffForm.daily_max_rate" type="number" class="form-control" /></div>
      </div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">Tarif Tambahan</label><input v-model.number="tariffForm.increment_rate" type="number" class="form-control" /></div>
        <div class="col-6"><label class="form-label">Menit Tambahan</label><input v-model.number="tariffForm.increment_minutes" type="number" class="form-control" /></div>
      </div>
      <div class="mb-3"><label class="form-label">Masa Tenggang (menit)</label><input v-model.number="tariffForm.grace_period_minutes" type="number" class="form-control" /></div>
      <div class="d-flex justify-content-end gap-2">
        <BButton variant="light" @click="showTariffModal=false">Batal</BButton>
        <BButton variant="primary" @click="saveTariff">Simpan</BButton>
      </div>
    </BModal>
  </Layout>
</template>
