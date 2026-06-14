<script>
export default {
  emits: ["search", "sort", "page-change", "per-page-change"],
  props: {
    columns: { type: Array, required: true },
    data: { type: Object, default: () => ({ data: [], current_page: 1, last_page: 1, total: 0, from: 0, to: 0 }) },
    searchable: { type: Boolean, default: true },
    sortField: { type: String, default: "" },
    sortDir: { type: String, default: "desc" },
    perPage: { type: Number, default: 15 },
    loading: { type: Boolean, default: false },
  },
  data() {
    return {
      searchQuery: "",
      searchTimer: null,
    };
  },
  computed: {
    sortIndicator() {
      return (key) => {
        if (this.sortField !== key) return "";
        return this.sortDir === "asc" ? "ri-arrow-up-s-line" : "ri-arrow-down-s-line";
      };
    },
    pageNumbers() {
      const pages = [];
      const { current_page, last_page } = this.data;
      const maxVisible = 7;
      let start = Math.max(1, current_page - Math.floor(maxVisible / 2));
      let end = Math.min(last_page, start + maxVisible - 1);
      if (end - start + 1 < maxVisible) {
        start = Math.max(1, end - maxVisible + 1);
      }
      for (let i = start; i <= end; i++) {
        pages.push(i);
      }
      return pages;
    },
  },
  methods: {
    onSort(key) {
      if (this.sortField === key) {
        this.$emit("sort", key, this.sortDir === "asc" ? "desc" : "asc");
      } else {
        this.$emit("sort", key, "asc");
      }
    },
    onSearch() {
      clearTimeout(this.searchTimer);
      this.searchTimer = setTimeout(() => {
        this.$emit("search", this.searchQuery);
      }, 300);
    },
    goPage(page) {
      if (page < 1 || page > this.data.last_page) return;
      this.$emit("page-change", page);
    },
    changePerPage(e) {
      this.$emit("per-page-change", parseInt(e.target.value));
    },
  },
};
</script>

<template>
  <div>
    <div v-if="searchable" class="row mb-3">
      <div class="col-md-6">
        <div class="search-box">
          <input
            type="text"
            class="form-control bg-light border-0"
            placeholder="Cari data..."
            v-model="searchQuery"
            @input="onSearch"
          />
          <i class="ri-search-line search-icon"></i>
        </div>
      </div>
      <div class="col-md-6 text-end">
        <div class="d-flex align-items-center justify-content-end gap-2">
          <small class="text-muted">Tampilkan</small>
          <select class="form-select form-select-sm" style="width:70px" :value="perPage" @change="changePerPage">
            <option :value="10">10</option>
            <option :value="15">15</option>
            <option :value="25">25</option>
            <option :value="50">50</option>
            <option :value="100">100</option>
          </select>
        </div>
      </div>
    </div>

    <div class="table-responsive table-card">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-light">
          <tr>
            <th
              v-for="col in columns"
              :key="col.key"
              :class="[
                col.class,
                { sort: col.sortable !== false },
                { sorting: sortField === col.key },
              ]"
              :style="col.width ? `width:${col.width}` : ''"
              @click="col.sortable !== false && onSort(col.key)"
              :scope="'col'"
            >
              <span v-if="col.label" class="d-flex align-items-center gap-1">
                {{ col.label }}
                <i v-if="col.sortable !== false" :class="sortIndicator(col.key)" class="sort-icon fs-12"></i>
              </span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td :colspan="columns.length" class="text-center py-4">
              <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
              Memuat data...
            </td>
          </tr>
          <tr v-else v-for="(row, i) in data.data || []" :key="row.id ?? i">
            <td v-for="col in columns" :key="col.key" :class="col.class">
              <slot :name="`cell-${col.key}`" :row="row" :value="row[col.key]">
                {{ row[col.key] ?? "-" }}
              </slot>
            </td>
          </tr>
          <tr v-if="!loading && (!data.data || !data.data.length)">
            <td :colspan="columns.length" class="text-center text-muted py-4">Belum ada data.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="data.last_page && data.last_page > 1" class="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
      <div class="text-muted small">
        Menampilkan {{ data.from || 0 }} - {{ data.to || 0 }} dari {{ data.total || 0 }}
      </div>
      <div class="pagination-wrap hstack gap-1">
        <button
          class="page-item pagination-prev btn btn-sm"
          :class="data.current_page <= 1 ? 'btn-soft-secondary disabled' : 'btn-soft-primary'"
          @click="goPage(data.current_page - 1)"
          :disabled="data.current_page <= 1"
        >
          <i class="ri-arrow-left-s-line"></i>
        </button>
        <button
          v-for="p in pageNumbers"
          :key="p"
          class="btn btn-sm"
          :class="p === data.current_page ? 'btn-primary' : 'btn-soft-primary'"
          @click="goPage(p)"
        >
          {{ p }}
        </button>
        <button
          class="page-item pagination-next btn btn-sm"
          :class="data.current_page >= data.last_page ? 'btn-soft-secondary disabled' : 'btn-soft-primary'"
          @click="goPage(data.current_page + 1)"
          :disabled="data.current_page >= data.last_page"
        >
          <i class="ri-arrow-right-s-line"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.sort { cursor: pointer; user-select: none; }
.sort:hover { color: #0ab39c; }
.sorting { color: #0ab39c !important; }
.sort-icon { opacity: 0.5; }
.sorting .sort-icon { opacity: 1; }
.search-box { position: relative; }
.search-box .form-control { padding-left: 36px; }
.search-box .search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #878a99; font-size: 16px; }
</style>
