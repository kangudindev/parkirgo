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
        { key: "7_hari", label: "7 hari", get: () => ({ from: this.fmt(new Date(new Date().setDate(new Date().getDate() - 6))), to: today }) },
        { key: "30_hari", label: "30 hari", get: () => ({ from: this.fmt(new Date(new Date().setDate(new Date().getDate() - 29))), to: today }) },
        { key: "bulan_ini", label: "Bulan ini", get: () => ({ from: this.fmt(new Date(y, m, 1)), to: today }) },
        { key: "bulan_lalu", label: "Bulan lalu", get: () => ({ from: this.fmt(new Date(y, m - 1, 1)), to: this.fmt(new Date(y, m, 0)) }) },
        { key: "tahun_ini", label: "Tahun ini", get: () => ({ from: this.fmt(new Date(y, 0, 1)), to: today }) },
      ],
    };
  },
  mounted() {
    // If props are provided, set initial values and active preset
    if (this.dateFrom && this.dateTo) {
      this.fromDate = this.dateFrom;
      this.toDate = this.dateTo;
      
      const today = this.fmt(new Date());
      if (this.dateFrom === today && this.dateTo === today) {
        this.activePreset = "hari_ini";
      } else {
        this.activePreset = "custom";
        this.customMode = true;
      }
    }
  },
  computed: {
    selectedLabel() {
      const preset = this.presets.find(p => p.key === this.activePreset);
      if (preset) return preset.label;
      if (this.activePreset === 'custom') return 'Custom Range';
      return 'Pilih Tanggal';
    }
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
      this.customMode = true;
      this.activePreset = "custom";
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
  <div class="date-filter-container">
    <div class="d-flex align-items-center gap-2 flex-wrap">
      <BDropdown variant="soft-primary" class="flex-shrink-0" toggle-class="btn-sm">
        <template #button-content>
          <i class="ri-calendar-event-line me-1"></i> {{ selectedLabel }}
        </template>
        <BDropdownItem v-for="p in presets" :key="p.key" @click="selectPreset(p)" :active="activePreset === p.key">
          {{ p.label }}
        </BDropdownItem>
        <BDropdownDivider />
        <BDropdownItem @click="toggleCustom" :active="activePreset === 'custom'">
          Custom Range
        </BDropdownItem>
      </BDropdown>

      <div v-if="customMode" class="d-flex align-items-center gap-2 animate-fade-in">
        <div style="width: 140px">
          <flat-pickr
            v-model="fromDate"
            :config="{ dateFormat: 'Y-m-d', altFormat: 'd M Y', altInput: true, allowInput: true }"
            class="form-control form-control-sm"
            placeholder="Dari"
          ></flat-pickr>
        </div>
        <i class="ri-arrow-right-line text-muted"></i>
        <div style="width: 140px">
          <flat-pickr
            v-model="toDate"
            :config="{ dateFormat: 'Y-m-d', altFormat: 'd M Y', altInput: true, allowInput: true }"
            class="form-control form-control-sm"
            placeholder="Sampai"
          ></flat-pickr>
        </div>
        <BButton variant="primary" size="sm" @click="applyCustom">
          <i class="ri-check-line"></i>
        </BButton>
      </div>
    </div>
  </div>
</template>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.3s ease-in-out;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateX(-10px); }
  to { opacity: 1; transform: translateX(0); }
}
</style>
