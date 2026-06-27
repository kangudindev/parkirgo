<script setup>
import { ref, watch } from 'vue';
import html2canvas from 'html2canvas';
import QRCode from 'qrcode';

const props = defineProps({
  subscription: {
    type: Object,
    required: true
  }
});

const idCardRef = ref(null);
const qrCodeUrl = ref('');

const generateQr = async () => {
  const qrText = props.subscription?.user?.qr_auth_token || `SUB-${props.subscription?.id || 'TEMP'}`;
  try {
    qrCodeUrl.value = await QRCode.toDataURL(qrText, { width: 300, margin: 2 });
  } catch (err) {
    console.error('Failed to generate local QR code:', err);
    qrCodeUrl.value = '';
  }
};

watch(() => [props.subscription?.user?.qr_auth_token, props.subscription?.id], generateQr, { immediate: true });

const downloadCard = async () => {
  if (!idCardRef.value) return;
  
  try {
    const canvas = await html2canvas(idCardRef.value, {
      useCORS: true,
      scale: 2,
      backgroundColor: null
    });
    
    const link = document.createElement('a');
    const memberName = props.subscription?.user?.name || props.subscription?.plate_number || 'Member';
    link.download = `MEMBER_CARD_${memberName.replace(/\s+/g, '_')}.png`;
    link.href = canvas.toDataURL('image/png');
    link.click();
  } catch (err) {
    console.error('Failed to generate Member Card image', err);
  }
};

const formatDate = (value) => {
  if (!value) return '-';
  return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium" }).format(new Date(value));
};

defineExpose({ downloadCard });
</script>

<template>
  <div class="member-card-container" ref="idCardRef">
    <div class="member-card-wrapper">
      <!-- Card Front -->
      <div class="member-card front">
        <div class="card-header">
          <div class="logo-section">
            <img src="/images/logo_parkirgo.png?v=2" alt="ParkirGo Logo" class="logo" />
          </div>
          <div class="vip-badge"><i class="ri-vip-crown-fill me-1 text-warning"></i>MEMBER LANGGANAN</div>
        </div>
        
        <div class="card-body">
          <div class="package-section">
            <span class="pack-label">PAKET AKTIF</span>
            <h4 class="pack-name text-truncate">{{ subscription.package?.name || 'UNLIMITED PASS' }}</h4>
          </div>
          
          <div class="info-section">
            <div class="info-group">
              <span class="label">NAMA MEMBER</span>
              <h5 class="value text-uppercase">{{ subscription.user?.name || 'PELANGGAN OFFLINE' }}</h5>
            </div>
            
            <div class="info-group mt-2" v-if="subscription.user?.phone">
              <span class="label">TELEPON/WA</span>
              <span class="value fs-13">{{ subscription.user.phone }}</span>
            </div>

            <div class="divider"></div>

            <div class="vehicles-group">
              <span class="label">KENDARAAN TERDAFTAR (PLAT NOMOR)</span>
              <div class="plates-list d-flex flex-wrap justify-content-center gap-2 mt-1">
                <span v-for="v in subscription.vehicles" :key="v.id" class="plate-badge">
                  <i class="ri-car-fill me-1 align-middle text-warning"></i>
                  <span class="fw-bold">{{ v.license_plate }}</span>
                </span>
                <span v-if="!subscription.vehicles || subscription.vehicles.length === 0" class="plate-badge text-muted">
                  Belum ada kendaraan
                </span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="card-footer">
          <div class="valid-thru">
            VALID UNTIL: <span class="text-warning fw-bold">{{ formatDate(subscription.end_date) }}</span>
          </div>
          <div class="card-chip"></div>
        </div>
      </div>

      <!-- Card Back -->
      <div class="member-card back">
        <div class="back-header">
          <h3>KARTU DIGITAL MEMBER PARKIRGO</h3>
        </div>
        
        <div class="back-body">
          <div class="qr-container text-center">
            <div class="qr-frame">
              <img v-if="qrCodeUrl" :src="qrCodeUrl" alt="QR Code Member" class="qr-code" />
              <div v-else class="qr-placeholder">QR NOT GENERATED</div>
            </div>
            <p class="qr-label mt-2"><i class="ri-scan-2-line text-primary me-1"></i>SCAN QR UNTUK VALIDASI PARKIR</p>
          </div>

          <ul class="rules mt-3">
            <li>Tunjukkan QR Code di atas ke Juru Parkir saat Check-In/Check-Out.</li>
            <li>Berlaku di seluruh area zona parkir terintegrasi ParkirGo.</li>
            <li>Hanya dapat digunakan untuk plat nomor terdaftar.</li>
          </ul>
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

.member-card-container {
  padding: 20px;
  background: transparent;
  display: inline-block;
}

.member-card-wrapper {
  display: flex;
  flex-direction: row;
  gap: 20px;
  align-items: center;
  font-family: 'Outfit', sans-serif;
}

.member-card {
  width: 320px;
  height: 500px;
  border-radius: 20px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.25);
  background: white;
  display: flex;
  flex-direction: column;
}

/* Front Card Styles */
.front {
  background: linear-gradient(135deg, #3c096c 0%, #1a0033 100%);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.card-header {
  padding: 30px 20px 15px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.logo {
  height: 38px;
  width: auto;
  filter: brightness(0) invert(1);
}

.vip-badge {
  background: rgba(255, 193, 7, 0.15);
  color: #ffc107;
  padding: 5px 15px;
  border-radius: 100px;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 1.5px;
  border: 1px solid rgba(255, 193, 7, 0.3);
}

.package-section {
  text-align: center;
  padding: 10px 15px;
  background: rgba(255, 255, 255, 0.05);
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.pack-label {
  font-size: 8px;
  font-weight: 600;
  letter-spacing: 2px;
  color: rgba(255, 255, 255, 0.5);
  display: block;
  margin-bottom: 2px;
}

.pack-name {
  font-size: 15px;
  font-weight: 700;
  color: #ffc107;
  margin-bottom: 0;
  text-transform: uppercase;
}

.info-section {
  padding: 20px 25px;
  text-align: center;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.info-group .label {
  font-size: 9px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.5);
  letter-spacing: 1.5px;
  display: block;
  margin-bottom: 3px;
}

.info-group .value {
  font-size: 19px;
  font-weight: 700;
  color: white;
  margin: 0;
}

.divider {
  height: 2px;
  width: 50px;
  background: rgba(255, 255, 255, 0.15);
  margin: 15px auto;
  border-radius: 10px;
}

.vehicles-group .label {
  font-size: 9px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.5);
  letter-spacing: 1.5px;
  display: block;
  margin-bottom: 5px;
}

.plate-badge {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 6px;
  padding: 4px 10px;
  font-size: 12px;
  display: inline-flex;
  align-items: center;
}

.card-footer {
  margin-top: auto;
  padding: 15px 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(0, 0, 0, 0.2);
}

.valid-thru {
  font-size: 10px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.7);
}

.card-chip {
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
  background: #3c096c;
  padding: 15px;
  text-align: center;
}

.back-header h3 {
  font-size: 12px;
  font-weight: 700;
  margin: 0;
  color: white;
  letter-spacing: 1px;
}

.back-body {
  padding: 25px;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.qr-frame {
  padding: 12px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  border: 1px solid #eee;
  display: inline-block;
}

.qr-code {
  width: 140px;
  height: 140px;
}

.qr-label {
  font-size: 9px;
  font-weight: 800;
  color: #3c096c;
  letter-spacing: 1px;
}

.rules {
  list-style: none;
  padding: 0;
  margin: 15px 0 0 0;
  font-size: 10px;
  color: #475569;
  line-height: 1.6;
}

.rules li {
  margin-bottom: 6px;
  position: relative;
  padding-left: 15px;
  text-align: left;
}

.rules li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #7b2cbf;
  font-weight: bold;
}

.back-footer {
  margin-top: auto;
  padding: 15px;
  text-align: center;
  background: #1e293b;
}

.app-info {
  font-size: 11px;
  color: #7b2cbf;
  font-weight: 700;
}
</style>
