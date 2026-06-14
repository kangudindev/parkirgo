<script>
import flatPickr from "vue-flatpickr-component";
import "flatpickr/dist/flatpickr.css";

export default {
  components: { flatPickr },
  props: {
    dateFrom: { type: String, default: "" },
    dateTo: { type: String, default: "" },
  },
  emits: ["change"],
  data() {
    const d = new Date();
    const y = d.getFullYear();
    const m = d.getMonth();
    const today = this.fmt(d);
    const yesterday = this.fmt(new Date(d.setDate(d.getDate() - 1)));

    return {
      activePreset: "bulan_ini",
      customMode: false,
      fromDate: this.dateFrom || this.fmt(new Date(y, m, 1)),
      toDate: this.dateTo || today,
      presets: [
        { key: "hari_ini", label: "Hari ini", get: () => ({ from: today, to: today }) },
        { key: "kemarin", label: "Kemarin", get: () => ({ from: yesterday, to: yesterday }) },
        { key: "7_hari", label: "7 hari", get: () => ({ from: this.fmt(new Date(y, m, d.getDate() - 6)), to: today }) },
        { key: "30_hari", label: "30 hari", get: () => ({ from: this.fmt(new Date(y, m, d.getDate() - 29)), to: today }) },
        { key: "bulan_ini", label: "Bulan ini", get: () => ({ from: this.fmt(new Date(y, m, 1)), to: today }) },
        { key: "bulan_lalu", label: "Bulan lalu", get: () => ({ from: this.fmt(new Date(y, m - 1, 1)), to: this.fmt(new Date(y, m, 0)) }) },
        { key: "tahun_ini", label: "Tahun ini", get: () => ({ from: this.fmt(new Date(y, 0, 1)), to: today }) },
      ],
    };
  },
  watch: {
    customMode(val) {
      if (val) this.activePreset = "custom";
    },
  },
  methods: {
    fmt(date) {
      return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
    },
    selectPreset(preset) {
      this.customMode = false;
      this.activePreset = preset.key;
      const range = preset.get();
      this.fromDate = range.from;
      this.toDate = range.to;
      this.$emit("change", { date_from: range.from, date_to: range.to, preset: preset.key });
    },
    toggleCustom() {
      this.customMode = !this.customMode;
      if (this.customMode) {
        this.activePreset = "custom";
      } else {
        this.fromDate = this.fmt(new Date());
        this.toDate = this.fmt(new Date());
      }
    },
    applyCustom() {
      if (this.fromDate && this.toDate) {
        this.$emit("change", { date_from: this.fromDate, date_to: this.toDate, preset: "custom" });
      }
    },
  },
};
</script>

<template>
  <div>
    <div class="d-flex flex-wrap gap-1 mb-3" role="group">
      <button
        v-for="p in presets"
        :key="p.key"
        type="button"
        class="btn btn-sm"
        :class="activePreset === p.key ? 'btn-primary' : 'btn-soft-primary'"
        @click="selectPreset(p)"
      >
        {{ p.label }}
      </button>
      <button
        type="button"
        class="btn btn-sm"
        :class="customMode ? 'btn-primary' : 'btn-soft-primary'"
        @click="toggleCustom"
      >
        <i class="ri-calendar-line me-1"></i>Custom Range
      </button>
    </div>

    <div v-if="customMode" class="row g-2 align-items-end">
      <div class="col-md-4">
        <label class="form-label mb-1 text-muted small">Dari Tanggal</label>
        <flat-pickr
          v-model="fromDate"
          :config="{ dateFormat: 'Y-m-d', altFormat: 'd M Y', altInput: true, allowInput: true }"
          class="form-control flatpickr-input"
          placeholder="Pilih tanggal"
        ></flat-pickr>
      </div>
      <div class="col-md-4">
        <label class="form-label mb-1 text-muted small">Sampai Tanggal</label>
        <flat-pickr
          v-model="toDate"
          :config="{ dateFormat: 'Y-m-d', altFormat: 'd M Y', altInput: true, allowInput: true }"
          class="form-control flatpickr-input"
          placeholder="Pilih tanggal"
        ></flat-pickr>
      </div>
      <div class="col-md-4 d-flex gap-2">
        <BButton variant="primary" @click="applyCustom">
          <i class="ri-filter-2-line me-1"></i>Tampilkan
        </BButton>
      </div>
    </div>
  </div>
</template>
