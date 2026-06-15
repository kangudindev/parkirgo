<script>
import { LMap, LTileLayer, LMarker } from "@vue-leaflet/vue-leaflet";
import { latLng } from "leaflet";
import "leaflet/dist/leaflet.css";

export default {
  components: { LMap, LTileLayer, LMarker },
  props: {
    visible: { type: Boolean, default: false },
    currentLat: { type: Number, default: null },
    currentLng: { type: Number, default: null },
  },
  emits: ["close", "select"],
  data() {
    return {
      zoom: 13,
      center: latLng(this.currentLat || -6.2, this.currentLng || 106.8),
      url: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
      marker: this.currentLat && this.currentLng ? { lat: this.currentLat, lng: this.currentLng } : null,
      searchQuery: "",
      searching: false,
      searchResults: [],
      mapInstance: null,
    };
  },
  computed: {
    isVisible: {
      get() { return this.visible; },
      set(val) { if (!val) this.$emit('close'); }
    }
  },
  watch: {
    visible(val) {
      if (val) {
        this.$nextTick(() => {
          setTimeout(() => {
            if (this.mapInstance) this.mapInstance.invalidateSize();
          }, 200);
        });
      }
    },
  },
  methods: {
    onMapReady(mapInstance) {
      this.mapInstance = mapInstance;
      setTimeout(() => {
        mapInstance.invalidateSize();
      }, 300);
    },
    onMapClick(e) {
      this.marker = { lat: e.latlng.lat, lng: e.latlng.lng };
      this.center = latLng(e.latlng.lat, e.latlng.lng);
    },
    onMarkerDrag(e) {
      this.marker = { lat: e.latlng.lat, lng: e.latlng.lng };
    },
    async searchLocation() {
      if (!this.searchQuery.trim()) return;
      this.searching = true;
      try {
        const res = await fetch(
          `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(this.searchQuery)}&limit=5&countrycodes=id`
        );
        const data = await res.json();
        this.searchResults = data;
      } catch (e) {
        this.searchResults = [];
      } finally {
        this.searching = false;
      }
    },
    selectResult(item) {
      const lat = parseFloat(item.lat);
      const lng = parseFloat(item.lon);
      this.center = latLng(lat, lng);
      this.zoom = 15;
      this.marker = { lat, lng };
      this.searchResults = [];
      this.searchQuery = item.display_name;
    },
    confirm() {
      if (this.marker) {
        this.$emit("select", { lat: this.marker.lat, lng: this.marker.lng, label: this.searchQuery || "Lokasi dipilih" });
      }
      this.$emit("close");
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>

<template>
  <BModal v-model="isVisible" title="Pilih Lokasi Zona" hide-footer centered size="xl">
    <div class="mb-3">
      <div class="input-group">
        <input
          type="text"
          class="form-control"
          placeholder="Cari lokasi, kota, atau tempat..."
          v-model="searchQuery"
          @keyup.enter="searchLocation"
        />
        <BButton variant="primary" @click="searchLocation" :disabled="searching">
          <i v-if="searching" class="ri-loader-4-line spin me-1"></i>
          <i v-else class="ri-search-line me-1"></i>
          Cari
        </BButton>
      </div>
      <div v-if="searchResults.length" class="list-group mt-2" style="max-height:200px;overflow-y:auto">
        <button
          v-for="(item, i) in searchResults"
          :key="i"
          class="list-group-item list-group-item-action py-2 small"
          @click="selectResult(item)"
        >
          <i class="ri-map-pin-2-line me-1 text-primary"></i>
          {{ item.display_name }}
        </button>
      </div>
    </div>

    <div style="height:450px;width:100%;border-radius:8px;overflow:hidden;background:#e9ecef">
      <l-map
        style="height:100%;width:100%"
        :zoom="zoom"
        :center="center"
        @click="onMapClick"
        @ready="onMapReady"
      >
        <l-tile-layer :url="url" :attribution="attribution" />
        <l-marker
          v-if="marker"
          :lat-lng="latLng(marker.lat, marker.lng)"
          :draggable="true"
          @moveend="onMarkerDrag"
        ></l-marker>
      </l-map>
    </div>

    <div v-if="marker" class="mt-2 small text-muted">
      <i class="ri-map-pin-2-line me-1"></i>
      Lat: {{ marker.lat.toFixed(6) }}, Lng: {{ marker.lng.toFixed(6) }}
    </div>

    <div class="d-flex justify-content-end gap-2 mt-3">
      <BButton variant="light" @click="close">Batal</BButton>
      <BButton variant="primary" @click="confirm" :disabled="!marker">
        <i class="ri-check-line me-1"></i>Gunakan Lokasi
      </BButton>
    </div>
  </BModal>
</template>

<style scoped>
.spin { animation: spin 1s linear infinite; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
</style>
