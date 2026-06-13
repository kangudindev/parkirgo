<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { router } from "@inertiajs/vue3";

export default {
  components: { Layout, PageHeader },
  props: {
    users: { type: Object, default: () => ({ data: [] }) },
    zones: { type: Array, default: () => [] },
  },
  data() {
    return {
      showModal: false,
      showQrModal: false,
      editing: null,
      qrUser: null,
      form: { name: '', email: '', nik: '', phone: '', role: 'jukir', status: 'active', assigned_zone_id: null, password: '' },
    };
  },
  methods: {
    roleLabel(role) {
      const labels = { admin: "Admin ParkirGo", supervisor: "Supervisor", jukir: "Juru Parkir" };
      return labels[role] || role || "-";
    },
    statusClass(status) {
      return status === "active" ? "success" : "secondary";
    },
    formatDate(value) {
      if (!value) return "-";
      return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
    },
    open(u) {
      this.editing = u;
      if (u) this.form = { name: u.name, email: u.email, nik: u.nik || '', phone: u.phone || '', role: u.role, status: u.status, assigned_zone_id: u.assigned_zone_id, password: '' };
      else this.form = { name: '', email: '', nik: '', phone: '', role: 'jukir', status: 'active', assigned_zone_id: null, password: '' };
      this.showModal = true;
    },
    save() {
      if (this.editing) {
        router.post(route('parkirgo.users.update', this.editing.id), { ...this.form, _method: 'PUT' }, { preserveScroll: true, onSuccess: () => this.showModal = false });
      } else {
        router.post(route('parkirgo.users.store'), this.form, { preserveScroll: true, onSuccess: () => this.showModal = false });
      }
    },
    remove(u) {
      if (!confirm(`Hapus pengguna ${u.name}?`)) return;
      router.delete(route('parkirgo.users.destroy', u.id), { preserveScroll: true });
    },
    generateQr(userId) {
      if (!confirm("Generate QR ID Card baru untuk pengguna ini? Kartu lama akan tidak berlaku.")) return;
      router.post(route("parkirgo.users.generate-qr", userId), {}, { preserveScroll: true });
    },
    revokeQr(userId) {
      if (!confirm("Cabut QR ID Card?")) return;
      router.post(route("parkirgo.users.revoke-qr", userId), {}, { preserveScroll: true });
    },
    showQr(user) {
      if (!user.qr_auth_token) return;
      this.qrUser = user;
      this.showQrModal = true;
    },
    copyToken(token) {
      navigator.clipboard.writeText(token);
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Manajemen Pengguna" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total Pengguna</p>
                <h3 class="mb-0">{{ users.total || users.data?.length || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-team-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Zona Aktif</p>
                <h3 class="mb-0">{{ zones.length }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-success-subtle text-success d-flex align-items-center justify-content-center">
                <i class="ri-map-pin-2-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BCard no-body class="border-0 shadow-sm">
      <BCardHeader class="d-flex align-items-center justify-content-between">
        <div>
          <BCardTitle class="mb-1">Daftar Pengguna</BCardTitle>
          <p class="text-muted mb-0">Akun admin, supervisor, dan juru parkir ParkirGo.</p>
        </div>
        <BButton variant="primary" @click="open(null)">
          <i class="ri-add-line me-1"></i>Tambah Pengguna
        </BButton>
      </BCardHeader>
      <BCardBody>
        <div class="table-responsive table-card">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr>
                <th>Nama</th>
                <th>NIK</th>
                <th>Role</th>
                <th>Zona</th>
                <th>Status</th>
                <th>QR ID Card</th>
                <th>Terakhir Online</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in users.data" :key="user.id">
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <img :src="user.profile_photo_url" :alt="user.name" class="rounded-circle avatar-xs" />
                    <span class="fw-semibold">{{ user.name }}</span>
                  </div>
                </td>
                <td>{{ user.nik || '-' }}</td>
                <td><span class="badge bg-info-subtle text-info">{{ roleLabel(user.role) }}</span></td>
                <td>{{ user.assigned_zone?.name || '-' }}</td>
                <td><span :class="`badge bg-${statusClass(user.status)}-subtle text-${statusClass(user.status)}`">{{ user.status }}</span></td>
                <td>
                  <span v-if="user.role === 'admin'" class="text-muted fst-italic">N/A</span>
                  <span v-else-if="user.has_qr_token" class="badge bg-success-subtle text-success">
                    <i class="ri-qr-code-line me-1"></i>Aktif
                  </span>
                  <span v-else class="badge bg-warning-subtle text-warning">
                    <i class="ri-qr-code-line me-1"></i>Belum
                  </span>
                </td>
                <td>{{ formatDate(user.last_seen_at) }}</td>
                <td>
                  <div v-if="user.role !== 'admin'" class="d-flex gap-1">
                    <BButton size="sm" variant="outline-secondary" @click="open(user)"><i class="ri-pencil-line"></i></BButton>
                    <BButton v-if="!user.has_qr_token" size="sm" variant="primary" @click="generateQr(user.id)">
                      <i class="ri-qr-code-line me-1"></i>Generate QR
                    </BButton>
                    <BButton v-if="user.has_qr_token" size="sm" variant="outline-info" @click="showQr(user)" title="Lihat QR ID Card">
                      <i class="ri-eye-line"></i>
                    </BButton>
                    <BButton v-else-if="user.role !== 'admin' && user.has_qr_token" size="sm" variant="outline-warning" @click="generateQr(user.id)" title="Regenerate QR">
                      <i class="ri-refresh-line me-1"></i>Re-Generate
                    </BButton>
                    <BButton v-if="user.has_qr_token" size="sm" variant="outline-danger" @click="revokeQr(user.id)" title="Cabut QR ID Card">
                      <i class="ri-forbid-line"></i>
                    </BButton>
                    <BButton size="sm" variant="outline-danger" @click="remove(user)"><i class="ri-delete-bin-line"></i></BButton>
                  </div>
                  <span v-else class="text-muted">-</span>
                </td>
              </tr>
              <tr v-if="!users.data?.length">
                <td colspan="8" class="text-center text-muted py-4">Belum ada data pengguna.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </BCardBody>
    </BCard>

    <!-- User Modal -->
    <BModal v-model="showModal" :title="editing ? 'Edit Pengguna' : 'Tambah Pengguna'" hide-footer>
      <div class="mb-2"><label class="form-label">Nama</label><input v-model="form.name" class="form-control" /></div>
      <div class="mb-2"><label class="form-label">Email</label><input v-model="form.email" type="email" class="form-control" /></div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">NIK</label><input v-model="form.nik" class="form-control" /></div>
        <div class="col-6"><label class="form-label">Telepon</label><input v-model="form.phone" class="form-control" /></div>
      </div>
      <div class="row mb-2">
        <div class="col-6"><label class="form-label">Role</label>
          <select v-model="form.role" class="form-select">
            <option value="admin">Admin ParkirGo</option>
            <option value="supervisor">Supervisor</option>
            <option value="jukir">Juru Parkir</option>
          </select>
        </div>
        <div class="col-6"><label class="form-label">Status</label>
          <select v-model="form.status" class="form-select">
            <option value="active">Aktif</option>
            <option value="inactive">Nonaktif</option>
          </select>
        </div>
      </div>
      <div class="mb-2"><label class="form-label">Zona</label>
        <select v-model="form.assigned_zone_id" class="form-select">
          <option value="">- Pilih Zona -</option>
          <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.name }}</option>
        </select>
      </div>
      <div class="mb-3">
        <label class="form-label">{{ editing ? 'Password Baru (kosongkan jika tidak diubah)' : 'Password' }}</label>
        <input v-model="form.password" type="password" class="form-control" />
      </div>
      <div class="d-flex justify-content-end gap-2">
        <BButton variant="light" @click="showModal=false">Batal</BButton>
        <BButton variant="primary" @click="save">Simpan</BButton>
      </div>
    </BModal>

    <!-- QR ID Card Modal -->
    <BModal v-model="showQrModal" title="QR ID Card" hide-footer centered size="md">
      <div v-if="qrUser" class="text-center py-3">
        <div class="mb-3">
          <img :src="`https://chart.googleapis.com/chart?chs=250x250&cht=qr&chl=${qrUser.qr_auth_token}`"
               alt="QR Code" class="img-fluid border rounded p-2" style="max-width:260px" />
        </div>
        <h5 class="mb-1">{{ qrUser.name }}</h5>
        <p class="text-muted mb-0">{{ qrUser.nik || '-' }} · {{ qrUser.assigned_zone?.name || '-' }}</p>
        <hr />
        <div class="d-flex align-items-center justify-content-center gap-2">
          <code class="bg-light px-2 py-1 rounded small">{{ qrUser.qr_auth_token }}</code>
          <BButton size="sm" variant="outline-secondary" @click="copyToken(qrUser.qr_auth_token)" title="Salin token">
            <i class="ri-file-copy-line"></i>
          </BButton>
        </div>
        <p class="text-muted small mt-2">Gunakan kode di atas untuk dicetak pada ID Card Juru Parkir.</p>
      </div>
    </BModal>
  </Layout>
</template>

<style scoped>
.stat-card { transition: transform .2s ease, box-shadow .2s ease; }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 18px 45px rgba(15, 23, 42, .12) !important; }
.avatar-xs { width: 32px; height: 32px; object-fit: cover; }
.avatar-sm { width: 48px; height: 48px; }
</style>
