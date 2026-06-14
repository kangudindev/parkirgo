<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";

export default {
  components: { Layout, PageHeader },
  props: {
    sessions: { type: Array, default: () => [] },
    attendances: { type: Array, default: () => [] },
  },
  methods: {
    badge(status) {
      return { active: "success", exited: "secondary", synced: "success", pending: "warning" }[status] || "info";
    },
    date(value) {
      return value ? new Date(value).toLocaleString("id-ID") : "-";
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Operasional Lapangan" pageTitle="ParkirGo" />

    <BRow>
      <BCol xl="8">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader class="d-flex align-items-center">
            <i class="ri-parking-box-line me-2 fs-18 text-primary"></i>
            <BCardTitle class="mb-0 flex-grow-1">Sesi Parkir</BCardTitle>
            <span class="badge bg-success-subtle text-success">Flat bayar masuk · Progresif bayar keluar</span>
          </BCardHeader>
          <BCardBody>
            <div class="table-responsive table-card">
              <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Tiket</th>
                    <th>Plat</th>
                    <th>Zona</th>
                    <th>Jukir</th>
                    <th>Masuk</th>
                    <th>Status</th>
                    <th>Bayar</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="session in sessions" :key="session.id">
                    <td class="fw-semibold">{{ session.ticket_number }}</td>
                    <td>{{ session.plate_number }}</td>
                    <td>{{ session.zone?.name }}</td>
                    <td>{{ session.jukir?.name }}</td>
                    <td>{{ date(session.entry_at) }}</td>
                    <td><span class="badge" :class="`bg-${badge(session.status)}-subtle text-${badge(session.status)}`">{{ session.status }}</span></td>
                    <td><span class="badge" :class="session.payment_status === 'paid' ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning'">{{ session.payment_status }}</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="4">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader>
            <i class="ri-user-check-line me-2 fs-18 text-info"></i>
            <BCardTitle class="mb-0">Absensi & Sync</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div v-for="attendance in attendances" :key="attendance.id" class="timeline-item border-start border-2 ps-3 pb-4">
              <div class="d-flex justify-content-between">
                <h6 class="mb-1">{{ attendance.user?.name }}</h6>
                <span class="badge" :class="`bg-${badge(attendance.sync_status)}-subtle text-${badge(attendance.sync_status)}`">{{ attendance.sync_status }}</span>
              </div>
              <p class="text-muted mb-1">{{ attendance.zone?.name }}</p>
              <small>Check-in: {{ date(attendance.check_in_at) }}</small><br />
              <small>Check-out: {{ date(attendance.check_out_at) }}</small>
            </div>
            <BAlert v-if="attendances.length === 0" variant="info" show class="mb-0">Belum ada data absensi.</BAlert>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>
  </Layout>
</template>

<style scoped>
.timeline-item { position: relative; }
.timeline-item::before { content: ""; position: absolute; left: -7px; top: 2px; width: 12px; height: 12px; border-radius: 999px; background: #0ab39c; box-shadow: 0 0 0 4px rgba(10,179,156,.12); }
</style>
