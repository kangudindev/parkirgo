<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";

export default {
  components: { Layout, PageHeader },
  props: {
    logs: { type: Object, default: () => ({ data: [] }) },
  },
  methods: {
    formatDate(value) {
      if (!value) return "-";
      return new Intl.DateTimeFormat("id-ID", {
        dateStyle: "medium",
        timeStyle: "short",
      }).format(new Date(value));
    },
    actionClass(action) {
      const actionText = (action || "").toLowerCase();
      if (actionText.includes("create") || actionText.includes("buat")) return "success";
      if (actionText.includes("update") || actionText.includes("ubah")) return "warning";
      if (actionText.includes("delete") || actionText.includes("hapus")) return "danger";
      if (actionText.includes("login")) return "primary";
      return "secondary";
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Audit Log" pageTitle="ParkirGo" />

    <BRow class="g-3 mb-4">
      <BCol md="4">
        <BCard no-body class="border-0 shadow-sm stat-card">
          <BCardBody>
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1">Total Aktivitas</p>
                <h3 class="mb-0">{{ logs.total || logs.data?.length || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-shield-check-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BCard no-body class="border-0 shadow-sm">
      <BCardHeader>
        <BCardTitle class="mb-1">Riwayat Aktivitas Sistem</BCardTitle>
        <p class="text-muted mb-0">Pantau perubahan data dan aktivitas penting pada ParkirGo.</p>
      </BCardHeader>
      <BCardBody>
        <div class="table-responsive table-card">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr>
                <th>Waktu</th>
                <th>Pengguna</th>
                <th>Aksi</th>
                <th>Entitas</th>
                <th>ID Entitas</th>
                <th>IP Address</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="log in logs.data" :key="log.id">
                <td>{{ formatDate(log.created_at) }}</td>
                <td>
                  <div class="fw-semibold">{{ log.user?.name || 'Sistem' }}</div>
                  <small class="text-muted">{{ log.user?.email || '-' }}</small>
                </td>
                <td><span :class="`badge bg-${actionClass(log.action)}-subtle text-${actionClass(log.action)}`">{{ log.action }}</span></td>
                <td>{{ log.entity_type || '-' }}</td>
                <td>{{ log.entity_id || '-' }}</td>
                <td>{{ log.ip_address || '-' }}</td>
              </tr>
              <tr v-if="!logs.data?.length">
                <td colspan="6" class="text-center text-muted py-4">Belum ada audit log.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </BCardBody>
    </BCard>
  </Layout>
</template>

<style scoped>
.stat-card { transition: transform .2s ease, box-shadow .2s ease; }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 18px 45px rgba(15, 23, 42, .12) !important; }
.avatar-sm { width: 48px; height: 48px; }
</style>
