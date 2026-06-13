<script setup>
import { computed } from 'vue';

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
});

const qrCodeUrl = computed(() => {
  if (!props.user?.qr_auth_token) return null;
  // Ganti ke QuickChart API agar lebih reliabel dibanding Google Charts (deprecated)
  return `https://quickchart.io/qr?text=${props.user.qr_auth_token}&size=300&margin=2`;
});

const printCard = () => {
  window.print();
};
</script>

<template>
  <div class="id-card-wrapper">
    <!-- ID Card Front -->
    <div class="id-card front">
      <div class="card-header">
        <div class="logo-section">
          <img src="/logo_parkirgo.png" alt="ParkirGo Logo" class="logo" />
          <div class="brand-name">
            <span class="parkir">Parkir</span><span class="go">Go</span>
          </div>
        </div>
        <div class="role-badge">JURU PARKIR</div>
      </div>
      
      <div class="card-body">
        <div class="profile-container">
          <div class="photo-frame">
            <img :src="user.profile_photo_url || '/image/default-avatar.png'" :alt="user.name" class="profile-photo" />
          </div>
        </div>
        
        <div class="info-section">
          <h2 class="user-name">{{ user.name }}</h2>
          <div class="user-nik">NIK: {{ user.nik || '---------' }}</div>
          <div class="divider"></div>
          <div class="zone-info">
            <span class="label">PENEMPATAN</span>
            <span class="value">{{ user.assigned_zone?.name || 'BELUM DITENTUKAN' }}</span>
          </div>
        </div>
      </div>
      
      <div class="card-footer">
        <div class="valid-thru">
          Valid Until: Dec 2026
        </div>
        <div class="security-chip"></div>
      </div>
    </div>

    <!-- ID Card Back -->
    <div class="id-card back">
      <div class="back-header">
        <h3>SYARAT & KETENTUAN</h3>
      </div>
      
      <div class="back-body">
        <ul class="rules">
          <li>Kartu ini adalah properti resmi ParkirGo.</li>
          <li>Wajib dikenakan selama bertugas di area parkir.</li>
          <li>Penyalahgunaan kartu dapat dikenakan sanksi.</li>
          <li>Jika menemukan kartu ini, harap hubungi Admin ParkirGo.</li>
        </ul>
        
        <div class="qr-container">
          <div class="qr-frame">
            <img v-if="qrCodeUrl" :src="qrCodeUrl" alt="QR Auth" class="qr-code" />
            <div v-else class="qr-placeholder">QR NOT GENERATED</div>
          </div>
          <p class="qr-label">SCAN UNTUK VERIFIKASI</p>
        </div>
      </div>
      
      <div class="back-footer">
        <div class="app-info">www.parkirgo.com</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap');

.id-card-wrapper {
  display: flex;
  flex-direction: column;
  gap: 30px;
  align-items: center;
  padding: 20px;
  font-family: 'Outfit', sans-serif;
  background: #f8fafc;
}

.id-card {
  width: 320px;
  height: 500px;
  border-radius: 20px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  background: white;
  display: flex;
  flex-direction: column;
}

/* Front Card Styles */
.front {
  background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
  color: white;
}

.front::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle at center, rgba(56, 189, 248, 0.1) 0%, transparent 70%);
  pointer-events: none;
}

.card-header {
  padding: 25px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 8px;
}

.logo {
  height: 32px;
  width: auto;
  filter: brightness(0) invert(1);
}

.brand-name {
  font-size: 22px;
  font-weight: 700;
  letter-spacing: -0.5px;
}

.parkir { color: #f8fafc; }
.go { color: #38bdf8; }

.role-badge {
  background: rgba(56, 189, 248, 0.15);
  color: #38bdf8;
  padding: 4px 12px;
  border-radius: 100px;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 2px;
  border: 1px solid rgba(56, 189, 248, 0.3);
}

.profile-container {
  display: flex;
  justify-content: center;
  padding: 10px 0;
}

.photo-frame {
  width: 140px;
  height: 140px;
  border-radius: 15px;
  border: 4px solid #38bdf8;
  padding: 4px;
  background: white;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
}

.profile-photo {
  width: 100%;
  height: 100%;
  border-radius: 8px;
  object-fit: cover;
}

.info-section {
  padding: 20px 25px;
  text-align: center;
}

.user-name {
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 4px;
  color: #f8fafc;
}

.user-nik {
  font-size: 13px;
  color: #94a3b8;
  letter-spacing: 1px;
}

.divider {
  height: 2px;
  background: linear-gradient(90deg, transparent, #38bdf8, transparent);
  margin: 15px 0;
  opacity: 0.5;
}

.zone-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.zone-info .label {
  font-size: 9px;
  font-weight: 600;
  color: #38bdf8;
  letter-spacing: 1.5px;
}

.zone-info .value {
  font-size: 14px;
  font-weight: 600;
  text-transform: uppercase;
}

.card-footer {
  margin-top: auto;
  padding: 20px 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(255, 255, 255, 0.05);
}

.valid-thru {
  font-size: 10px;
  color: #64748b;
}

.security-chip {
  width: 35px;
  height: 25px;
  background: linear-gradient(135deg, #e2e8f0 0%, #94a3b8 100%);
  border-radius: 4px;
  opacity: 0.6;
}

/* Back Card Styles */
.back {
  background: #ffffff;
  color: #1e293b;
  border: 1px solid #e2e8f0;
}

.back-header {
  background: #f1f5f9;
  padding: 20px;
  text-align: center;
}

.back-header h3 {
  font-size: 14px;
  font-weight: 700;
  margin: 0;
  color: #475569;
  letter-spacing: 1px;
}

.back-body {
  padding: 30px 25px;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.rules {
  list-style: none;
  padding: 0;
  margin: 0 0 40px 0;
  font-size: 11px;
  color: #64748b;
  line-height: 1.6;
}

.rules li {
  margin-bottom: 8px;
  position: relative;
  padding-left: 15px;
}

.rules li::before {
  content: '•';
  position: absolute;
  left: 0;
  color: #38bdf8;
  font-weight: bold;
}

.qr-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.qr-frame {
  padding: 10px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f5f9;
}

.qr-code {
  width: 140px;
  height: 140px;
}

.qr-placeholder {
  width: 140px;
  height: 140px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  color: #cbd5e1;
  text-align: center;
}

.qr-label {
  font-size: 10px;
  font-weight: 700;
  color: #94a3b8;
  letter-spacing: 1px;
}

.back-footer {
  margin-top: auto;
  padding: 15px;
  text-align: center;
  background: #0f172a;
}

.app-info {
  font-size: 11px;
  color: #38bdf8;
  font-weight: 600;
}

/* Print Styles */
@media print {
  body * {
    visibility: hidden;
  }
  .id-card-wrapper, .id-card-wrapper * {
    visibility: visible;
  }
  .id-card-wrapper {
    position: absolute;
    left: 0;
    top: 0;
    padding: 0;
    gap: 50px;
  }
  .id-card {
    box-shadow: none;
    border: 1px solid #eee;
    page-break-after: always;
  }
}
</style>
