<script>
import { watch } from "vue";
import { usePage } from "@inertiajs/vue3";

export default {
  name: "FlashToast",
  setup() {
    const page = usePage();

    watch(
      () => [page.props.flash?.success, page.props.flash?.error],
      ([success, error]) => {
        if (success || error) {
          const msg = success || error;
          const type = success ? "success" : "danger";
          const toastEl = document.createElement("div");
          toastEl.className = `toast align-items-center text-bg-${type} border-0 position-fixed top-0 end-0 m-4`;
          toastEl.setAttribute("role", "alert");
          toastEl.setAttribute("aria-live", "assertive");
          toastEl.setAttribute("aria-atomic", "true");
          toastEl.style.zIndex = "9999";
          toastEl.innerHTML = `
            <div class="d-flex">
              <div class="toast-body">${msg}</div>
              <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>`;
          document.body.appendChild(toastEl);
          const toast = new bootstrap.Toast(toastEl, { delay: 4000 });
          toast.show();
          toastEl.addEventListener("hidden.bs.toast", () => toastEl.remove());
        }
      },
      { deep: true }
    );

    return {};
  },
  render() {
    return null;
  },
};
</script>
