<script>
import "leaflet/dist/leaflet.css";
import L from "leaflet";

export default {
  props: {
    visible: { type: Boolean, default: false },
    currentLat: { type: Number, default: null },
    currentLng: { type: Number, default: null },
  },
  emits: ["close", "select"],
  data() {
    return {
      map: null,
      marker: null,
      zoom: 13,
      center: [this.currentLat || -6.2, this.currentLng || 106.8],
      searchQuery: "",
      searching: false,
      searchResults: [],
      selectedLabel: "",
    };
  },
  computed: {
    isVisible: {
      get() { return this.visible; },
      set(val) { if (!val) this.$emit("close"); }
    }
  },
  watch: {
    visible(val) {
      if (val) {
        setTimeout(() => this.initMap(), 350);
      }
    },
  },
  methods: {
    initMap() {
      this.destroyMap();
      const el = document.querySelector("#leaflet-map");
      if (!el) { console.warn("leaflet-map element not found"); return; }
      // Reset inner HTML to prevent duplicate initialization
      el.innerHTML = "";

      this.map = L.map(el, {
        center: this.center,
        zoom: this.zoom,
        zoomControl: true,
      });

      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a>',
        maxZoom: 19,
      }).addTo(this.map);

      setTimeout(() => this.map.invalidateSize(), 250);

      if (this.currentLat && this.currentLng) {
        this.placeMarker(this.currentLat, this.currentLng);
      }

      this.map.on("click", (e) => {
        this.placeMarker(e.latlng.lat, e.latlng.lng);
      });
    },
    destroyMap() {
      if (this.map) {
        this.map.remove();
        this.map = null;
        this.marker = null;
      }
    },
    placeMarker(lat, lng) {
      if (this.marker) this.map.removeLayer(this.marker);
      const icon = L.icon({
        iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
        iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
        shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41],
      });
      this.marker = L.marker([lat, lng], { icon, draggable: true }).addTo(this.map);
      this.marker.on("dragend", () => {
        const pos = this.marker.getLatLng();
        this.center = [pos.lat, pos.lng];
      });
      this.center = [lat, lng];
    },
    async searchLocation() {
      if (!this.searchQuery.trim()) return;
      this.searching = true;
      try {
        const res = await fetch(
          `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(this.searchQuery)}&limit=5&countrycodes=id`,
          { headers: { "Accept-Language": "id", "User-Agent": "ParkirGoApp/1.0" } }
        );
        if (!res.ok) throw new Error("HTTP " + res.status);
        const data = await res.json();
        this.searchResults = data;
      } catch (e) {
        console.warn("Search error:", e);
        this.searchResults = [];
      } finally {
        this.searching = false;
      }
    },
    selectResult(item) {
      const lat = parseFloat(item.lat);
      const lng = parseFloat(item.lon);
      this.searchResults = [];
      this.searchQuery = item.display_name;
      this.selectedLabel = item.display_name;

      if (this.map) {
        this.map.flyTo([lat, lng], 16, { duration: 1 });
        setTimeout(() => this.placeMarker(lat, lng), 1200);
      } else {
        this.center = [lat, lng];
        this.zoom = 16;
      }
    },
    confirm() {
      if (this.center) {
        this.$emit("select", { lat: this.center[0], lng: this.center[1], label: this.selectedLabel || this.searchQuery });
      }
      this.$emit("close");
    },
    close() {
      this.$emit("close");
    },
  },
  beforeUnmount() {
    this.destroyMap();
  },
};
</script>

<template>
  <BModal v-model="isVisible" title="Pilih Lokasi Zona" hide-footer centered size="xl" @hidden="destroyMap">
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
      <div v-if="searchResults.length" class="list-group mt-2" style="max-height:180px;overflow-y:auto">
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

    <div id="leaflet-map" style="height:450px;width:100%;border-radius:8px;overflow:hidden;background:#e9ecef;z-index:1"></div>

    <div v-if="center" class="mt-2 small text-muted">
      <i class="ri-map-pin-2-line me-1"></i>
      Lat: {{ center[0].toFixed(6) }}, Lng: {{ center[1].toFixed(6) }}
    </div>

    <div class="d-flex justify-content-end gap-2 mt-3">
      <BButton variant="light" @click="close">Batal</BButton>
      <BButton variant="primary" @click="confirm" :disabled="!center">
        <i class="ri-check-line me-1"></i>Gunakan Lokasi
      </BButton>
    </div>
  </BModal>
</template>

<style scoped>
.spin { animation: spin 1s linear infinite; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
#leaflet-map { position: relative; }
</style>
<style>
.leaflet-container { border-radius: 8px; z-index: 1; }
</style>
