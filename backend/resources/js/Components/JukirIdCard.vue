<script setup>
import { computed, ref } from 'vue';
import html2canvas from 'html2canvas';

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
});

const idCardRef = ref(null);

const qrCodeUrl = computed(() => {
  if (!props.user?.qr_auth_token) return null;
  return `https://quickchart.io/qr?text=${props.user.qr_auth_token}&size=300&margin=2`;
});

const downloadCard = async () => {
  if (!idCardRef.value) return;
  
  try {
    const canvas = await html2canvas(idCardRef.value, {
      useCORS: true,
      scale: 2,
      backgroundColor: null
    });
    
    const link = document.createElement('a');
    link.download = `ID_CARD_${props.user.name.replace(/\s+/g, '_')}.png`;
    link.href = canvas.toDataURL('image/png');
    link.click();
  } catch (err) {
    console.error('Failed to generate ID card image', err);
  }
};

defineExpose({ downloadCard });
</script>

<template>
  <div class="id-card-container" ref="idCardRef">
    <div class="id-card-wrapper">
      <!-- ID Card Front -->
      <div class="id-card front">
        <div class="card-header">
          <div class="logo-section">
            <img src="/images/logo_parkirgo.png" alt="ParkirGo Logo" class="logo" />
          </div>
          <div class="role-badge">JURU PARKIR</div>
        </div>
        
        <div class="card-body">
          <div class="profile-container">
            <div class="photo-frame">
              <img :src="user.profile_photo_url || '/images/avatar-1.jpg'" :alt="user.name" class="profile-photo" />
            </div>
          </div>
          
          <div class="info-section">
            <h2 class="user-name">{{ user.name }}</h2>
            <div class="user-nik">NIK: {{ user.nik || '---------' }}</div>
            <div class="divider"></div>
            <div class="zone-info">
              <span class="label">PENEMPATAN ZONA</span>
              <span class="value">{{ user.assigned_zone?.name || 'BELUM DITENTUKAN' }}</span>
            </div>
          </div>
        </div>
        
        <div class="card-footer">
          <div class="valid-thru">
            VALID THRU: 12/26
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
            <li>Jika menemukan kartu ini, harap hubungi Admin.</li>
          </ul>
          
          <div class="qr-container">
            <div class="qr-frame">
              <img v-if="qrCodeUrl" :src="qrCodeUrl" alt="QR Auth" class="qr-code" />
              <div v-else class="qr-placeholder">QR NOT GENERATED</div>
            </div>
            <p class="qr-label">AUTH LOGIN QRIS</p>
          </div>
        </div>
        
        <div class="back-footer">
          <div class="app-info">PARKIRGO DIGITAL SYSTEM</div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap');

.id-card-container {
  padding: 20px;
  background: transparent;
  display: inline-block;
}

.id-card-wrapper {
  display: flex;
  flex-direction: row;
  gap: 20px;
  align-items: center;
  font-family: 'Outfit', sans-serif;
}

.id-card {
  width: 320px;
  height: 500px;
  border-radius: 20px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
  background: white;
  display: flex;
  flex-direction: column;
}

/* Front Card Styles */
.front {
  background: linear-gradient(135deg, #25a0e2 0%, #1d80b5 100%);
  color: white;
  border: 1px solid rgba(255,255,255,0.1);
}

.card-header {
  padding: 30px 20px 20px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
}

.logo {
  height: 45px;
  width: auto;
  filter: brightness(0) invert(1);
}

.role-badge {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  padding: 5px 15px;
  border-radius: 100px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 2px;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.profile-container {
  display: flex;
  justify-content: center;
  padding: 10px 0;
}

.photo-frame {
  width: 160px;
  height: 160px;
  border-radius: 50%;
  border: 5px solid white;
  padding: 0;
  background: #eee;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.profile-photo {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.info-section {
  padding: 20px 25px;
  text-align: center;
}

.user-name {
  font-size: 24px;
  font-weight: 700;
  margin-bottom: 5px;
  color: white;
  text-transform: uppercase;
}

.user-nik {
  font-size: 14px;
  color: rgba(255,255,255,0.8);
  letter-spacing: 1px;
}

.divider {
  height: 3px;
  width: 60px;
  background: white;
  margin: 15px auto;
  border-radius: 10px;
}

.zone-info .label {
  font-size: 10px;
  font-weight: 600;
  color: rgba(255,255,255,0.7);
  letter-spacing: 1.5px;
  display: block;
  margin-bottom: 3px;
}

.zone-info .value {
  font-size: 16px;
  font-weight: 700;
}

.card-footer {
  margin-top: auto;
  padding: 20px 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(0, 0, 0, 0.1);
}

.valid-thru {
  font-size: 11px;
  font-weight: 600;
}

.security-chip {
  width: 40px;
  height: 30px;
  background: linear-gradient(135deg, #ffd700 0%, #b8860b 100%);
  border-radius: 6px;
}

/* Back Card Styles */
.back {
  background: #ffffff;
  color: #1e293b;
  border: 1px solid #e2e8f0;
}

.back-header {
  background: #25a0e2;
  padding: 20px;
  text-align: center;
}

.back-header h3 {
  font-size: 14px;
  font-weight: 700;
  margin: 0;
  color: white;
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
  margin: 0 0 35px 0;
  font-size: 11px;
  color: #475569;
  line-height: 1.8;
}

.rules li {
  margin-bottom: 8px;
  position: relative;
  padding-left: 15px;
}

.rules li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #25a0e2;
  font-weight: bold;
}

.qr-frame {
  padding: 12px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  border: 1px solid #eee;
}

.qr-code {
  width: 150px;
  height: 150px;
}

.qr-label {
  font-size: 11px;
  font-weight: 800;
  color: #1e293b;
  letter-spacing: 1px;
  margin-top: 15px;
}

.back-footer {
  margin-top: auto;
  padding: 15px;
  text-align: center;
  background: #1e293b;
}

.app-info {
  font-size: 11px;
  color: #25a0e2;
  font-weight: 700;
}
</style>
</style>
