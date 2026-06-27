<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { Link } from "@inertiajs/vue3";
import "leaflet/dist/leaflet.css";
import L from "leaflet";

export default {
  components: { Layout, PageHeader, Link },
  props: {
    zone: { type: Object, required: true },
  },
  data() {
    return {
      map: null,
    };
  },
  mounted() {
    if (this.zone.center_lat && this.zone.center_lng) {
      setTimeout(() => this.initMap(), 400);
    }
  },
  beforeUnmount() {
    if (this.map) {
      this.map.remove();
      this.map = null;
    }
  },
  methods: {
    initMap() {
      const lat = this.zone.center_lat;
      const lng = this.zone.center_lng;
      const radius = this.zone.radius_meters || 150;

      const el = document.querySelector("#zone-detail-map");
      if (!el) {
        console.warn("Element #zone-detail-map not found");
        return;
      }
      el.innerHTML = "";

      this.map = L.map(el, {
        center: [lat, lng],
        zoom: 15,
        zoomControl: true,
      });

      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a>',
        maxZoom: 19,
      }).addTo(this.map);

      const icon = L.icon({
        iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
        iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
        shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41],
      });

      L.marker([lat, lng], { icon })
        .addTo(this.map)
        .bindPopup(`<b>${this.zone.name}</b><br>Radius Absensi: ${radius}m`)
        .openPopup();

      L.circle([lat, lng], {
        color: "#405189",
        fillColor: "#405189",
        fillOpacity: 0.15,
        radius: radius,
      }).addTo(this.map);

      setTimeout(() => this.map.invalidateSize(), 200);
    },
    formatRp(v) {
      return "Rp " + Number(v).toLocaleString("id-ID");
    },
    typeLabel(t) {
      return t === "flat" ? "Flat" : "Progresif";
    },
    timingLabel(t) {
      return t === "entry" ? "Bayar Masuk" : "Bayar Keluar";
    },
    statusClass(status) {
      return status === "active" ? "success" : "danger";
    },
    roleLabel(role) {
      const labels = { admin: "Admin ParkirGo", supervisor: "Supervisor", jukir: "Juru Parkir" };
      return labels[role] || role || "-";
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader :title="`Detail Zona: ${zone.name}`" pageTitle="Zona & Tarif" />

    <!-- Bar Aksi / Navigasi Kembali -->
    <div class="d-flex align-items-center justify-content-between mb-4">
      <Link :href="route('parkirgo.zones')" class="btn btn-outline-secondary d-flex align-items-center">
        <i class="ri-arrow-left-line me-1"></i> Kembali ke Daftar Zona
      </Link>
      <span :class="`badge bg-${statusClass(zone.status)}-subtle text-${statusClass(zone.status)} px-3 py-2 fs-13 text-capitalize`">
        <i class="ri-checkbox-blank-circle-fill me-1 align-middle fs-10"></i> {{ zone.status }}
      </span>
    </div>

    <!-- Ringkasan Statistik Kartu -->
    <BRow class="g-3 mb-4">
      <BCol md="3">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody class="p-3">
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 text-uppercase fs-12 fw-semibold">Juru Parkir</p>
                <h3 class="mb-0 fw-bold">{{ zone.jukirs_count || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-user-star-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol md="3">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody class="p-3">
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 text-uppercase fs-12 fw-semibold">Kapasitas Jenis Kendaraan</p>
                <h3 class="mb-0 fw-bold">{{ (zone.vehicle_types || []).filter(vt => (vt.pivot?.capacity || 0) > 0).length }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-success-subtle text-success d-flex align-items-center justify-content-center">
                <i class="ri-car-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol md="3">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody class="p-3">
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 text-uppercase fs-12 fw-semibold">Total Sesi Parkir</p>
                <h3 class="mb-0 fw-bold">{{ zone.parking_sessions_count || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-info-subtle text-info d-flex align-items-center justify-content-center">
                <i class="ri-time-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol md="3">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody class="p-3">
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 text-uppercase fs-12 fw-semibold">Total Transaksi</p>
                <h3 class="mb-0 fw-bold">{{ zone.transactions_count || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-warning-subtle text-warning d-flex align-items-center justify-content-center">
                <i class="ri-money-dollar-circle-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BRow class="g-4">
      <!-- Kolom Kiri: Detail Informasi & Tarif -->
      <BCol lg="8">
        <!-- Informasi Utama -->
        <BCard no-body class="border-0 shadow-sm mb-4">
          <BCardHeader class="bg-transparent border-bottom">
            <BCardTitle class="mb-0"><i class="ri-information-line me-1 align-middle text-primary"></i> Informasi Utama Zona</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div class="row g-3">
              <div class="col-sm-6">
                <div class="bg-light p-3 rounded">
                  <span class="text-muted small d-block">Nama Zona</span>
                  <span class="fw-semibold text-dark fs-15">{{ zone.name }}</span>
                </div>
              </div>
              <div class="col-sm-6">
                <div class="bg-light p-3 rounded">
                  <span class="text-muted small d-block">Kode Zona</span>
                  <span class="fw-semibold text-dark fs-15">{{ zone.code }}</span>
                </div>
              </div>
              <div class="col-sm-6">
                <div class="bg-light p-3 rounded">
                  <span class="text-muted small d-block">Kota</span>
                  <span class="fw-semibold text-dark fs-15">{{ zone.city || "-" }}</span>
                </div>
              </div>
              <div class="col-sm-6">
                <div class="bg-light p-3 rounded">
                  <span class="text-muted small d-block">Radius Absensi</span>
                  <span class="fw-semibold text-dark fs-15">{{ zone.radius_meters ? zone.radius_meters + " meter" : "-" }}</span>
                </div>
              </div>
              <div class="col-sm-6">
                <div class="bg-light p-3 rounded">
                  <span class="text-muted small d-block">Latitude</span>
                  <span class="fw-semibold text-dark fs-15">{{ zone.center_lat || "-" }}</span>
                </div>
              </div>
              <div class="col-sm-6">
                <div class="bg-light p-3 rounded">
                  <span class="text-muted small d-block">Longitude</span>
                  <span class="fw-semibold text-dark fs-15">{{ zone.center_lng || "-" }}</span>
                </div>
              </div>
            </div>
          </BCardBody>
        </BCard>

        <!-- Kapasitas Kendaraan -->
        <BCard no-body class="border-0 shadow-sm mb-4">
          <BCardHeader class="bg-transparent border-bottom">
            <BCardTitle class="mb-0"><i class="ri-car-fill me-1 align-middle text-primary"></i> Kapasitas Jenis Kendaraan</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div v-if="(zone.vehicle_types || []).some(vt => vt.pivot?.capacity > 0)" class="row g-3">
              <div v-for="vt in zone.vehicle_types" :key="vt.id" class="col-md-6" v-show="vt.pivot?.capacity > 0">
                <div class="border rounded p-3 d-flex align-items-center justify-content-between">
                  <div class="d-flex align-items-center">
                    <div class="avatar-xs bg-primary-subtle text-primary rounded-circle d-flex align-items-center justify-content-center me-3">
                      <i :class="vt.icon || 'ri-car-line'" class="fs-18"></i>
                    </div>
                    <div>
                      <h6 class="mb-0 fw-semibold">{{ vt.name }}</h6>
                      <span class="text-muted small">Maksimal Parkir</span>
                    </div>
                  </div>
                  <div>
                    <span class="fs-4 fw-bold text-primary">{{ vt.pivot.capacity }}</span> <span class="text-muted small">Slot</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="text-center py-4 text-muted">
              <i class="ri-inbox-line fs-36 d-block mb-2 text-secondary"></i>
              Belum ada kapasitas kendaraan yang diatur untuk zona ini.
            </div>
          </BCardBody>
        </BCard>

        <!-- Tarif Parkir -->
        <BCard no-body class="border-0 shadow-sm mb-4">
          <BCardHeader class="bg-transparent border-bottom d-flex align-items-center justify-content-between">
            <BCardTitle class="mb-0"><i class="ri-price-tag-3-line me-1 align-middle text-primary"></i> Tarif Parkir Khusus Zona</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div class="table-responsive">
              <table class="table table-hover align-middle">
                <thead class="table-light text-muted">
                  <tr>
                    <th>Kendaraan</th>
                    <th>Tipe Tarif</th>
                    <th>Waktu Pembayaran</th>
                    <th>Tarif Dasar</th>
                    <th>Tambahan</th>
                    <th>Maks Harian</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="t in zone.tariffs" :key="t.id">
                    <td class="fw-semibold">
                      <div class="d-flex align-items-center">
                        <i :class="t.vehicle_type_master?.icon || 'ri-car-line'" class="text-primary fs-18 me-2"></i>
                        {{ t.vehicle_type_master?.name || "-" }}
                      </div>
                    </td>
                    <td><span class="badge bg-info-subtle text-info">{{ typeLabel(t.pricing_type) }}</span></td>
                    <td>{{ timingLabel(t.payment_timing) }}</td>
                    <td>{{ formatRp(t.base_rate) }}{{ t.base_minutes ? " / " + t.base_minutes + "m" : "" }}</td>
                    <td>{{ t.increment_rate ? formatRp(t.increment_rate) + " / " + t.increment_minutes + "m" : "-" }}</td>
                    <td>{{ t.daily_max_rate ? formatRp(t.daily_max_rate) : "-" }}</td>
                  </tr>
                  <tr v-if="!(zone.tariffs || []).length">
                    <td colspan="6" class="text-center py-4 text-muted">
                      <i class="ri-price-tag-3-line fs-36 d-block mb-2 text-secondary"></i>
                      Belum ada tarif yang dikonfigurasikan khusus untuk zona ini.
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </BCardBody>
        </BCard>
      </BCol>

      <!-- Kolom Kanan: Peta, QRIS & Jukir -->
      <BCol lg="4">
        <!-- Peta Lokasi -->
        <BCard no-body class="border-0 shadow-sm mb-4">
          <BCardHeader class="bg-transparent border-bottom">
            <BCardTitle class="mb-0"><i class="ri-map-pin-2-line me-1 align-middle text-primary"></i> Peta Lokasi & Radius</BCardTitle>
          </BCardHeader>
          <BCardBody class="p-2">
            <div v-if="zone.center_lat && zone.center_lng" id="zone-detail-map" class="zone-map-container"></div>
            <div v-else class="text-center py-5 text-muted">
              <i class="ri-map-pin-warning-line fs-40 text-warning mb-2 d-block"></i>
              Koordinat peta belum diatur untuk zona ini.
            </div>
          </BCardBody>
        </BCard>

        <!-- QRIS Pembayaran -->
        <BCard no-body class="border-0 shadow-sm mb-4">
          <BCardHeader class="bg-transparent border-bottom">
            <BCardTitle class="mb-0"><i class="ri-qr-code-line me-1 align-middle text-primary"></i> QRIS Pembayaran</BCardTitle>
          </BCardHeader>
          <BCardBody class="text-center">
            <div v-if="zone.qris_image_path">
              <div v-if="zone.qris_merchant_name" class="alert alert-info py-2 px-3 mb-3 text-start small">
                <i class="ri-store-2-line me-1 align-middle"></i>
                <span>Merchant: <strong>{{ zone.qris_merchant_name }}</strong></span>
              </div>
              <div class="p-3 bg-light rounded d-inline-block border mb-3">
                <img :src="`/storage/${zone.qris_image_path}`" alt="QRIS Code" class="img-fluid" style="max-height: 200px;" />
              </div>
              <a :href="`/storage/${zone.qris_image_path}`" download target="_blank" class="btn btn-sm btn-light w-100 mb-2">
                <i class="ri-download-line me-1"></i> Download Gambar QRIS
              </a>
            </div>
            <div v-else class="py-4 text-muted">
              <i class="ri-qr-code-line fs-40 d-block mb-2 text-secondary"></i>
              Gambar QRIS belum diunggah.
            </div>
          </BCardBody>
        </BCard>

        <!-- Juru Parkir Terdaftar -->
        <BCard no-body class="border-0 shadow-sm mb-4">
          <BCardHeader class="bg-transparent border-bottom">
            <BCardTitle class="mb-0"><i class="ri-user-star-line me-1 align-middle text-primary"></i> Juru Parkir Bertugas ({{ zone.jukirs_count || 0 }})</BCardTitle>
          </BCardHeader>
          <BCardBody class="p-0">
            <div v-if="(zone.jukirs || []).length" class="list-group list-group-flush">
              <div v-for="jukir in zone.jukirs" :key="jukir.id" class="list-group-item list-group-item-action border-0 py-3">
                <div class="d-flex align-items-center">
                  <img :src="jukir.profile_photo_url" :alt="jukir.name" class="rounded-circle avatar-xs me-3 img-thumbnail" style="width: 42px; height: 42px; object-fit: cover;" />
                  <div class="flex-grow-1">
                    <h6 class="mb-0 fw-semibold">{{ jukir.name }}</h6>
                    <span class="text-muted small d-block"><i class="ri-phone-line me-1 fs-11 align-middle"></i>{{ jukir.phone || "-" }}</span>
                  </div>
                  <div>
                    <span class="text-capitalize fs-10" :class="`badge bg-${jukir.status === 'active' ? 'success' : 'secondary'}-subtle text-${jukir.status === 'active' ? 'success' : 'secondary'}`">
                      {{ jukir.status }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="text-center py-4 text-muted">
              <i class="ri-user-unfollow-line fs-36 d-block mb-2 text-secondary"></i>
              Belum ada Juru Parkir yang ditugaskan ke zona ini.
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>
  </Layout>
</template>

<style scoped>
.stat-card {
  transition: transform .2s ease, box-shadow .2s ease;
}
.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 18px 45px rgba(15, 23, 42, .12) !important;
}
.zone-map-container {
  height: 250px;
  width: 100%;
  border-radius: 6px;
  overflow: hidden;
  background: #e9ecef;
  z-index: 1;
}
.avatar-xs {
  width: 32px;
  height: 32px;
}
.avatar-sm {
  width: 48px;
  height: 48px;
}
</style>
<style>
.leaflet-container {
  border-radius: 6px;
  z-index: 1;
}
</style>
