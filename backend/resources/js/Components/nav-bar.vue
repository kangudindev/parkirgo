<script>
import { Link, router } from '@inertiajs/vue3';
import simplebar from "simplebar-vue";
import i18n from "../i18n";
import { layoutMethods } from "@/state/helpers";

export default {
  data() {
    return {
      currentTime: "",
      timer: null,
      lan: i18n.locale,
    };
  },
  components: {
    simplebar,
    Link,
  },
  methods: {
    ...layoutMethods,
    logout() {
      router.post(route('logout'));
    },
    updateTime() {
      const now = new Date();
      const days = ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"];
      const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
      
      const day = days[now.getDay()];
      const date = now.getDate();
      const month = months[now.getMonth()];
      const year = now.getFullYear();
      
      const hours = String(now.getHours()).padStart(2, "0");
      const minutes = String(now.getMinutes()).padStart(2, "0");
      const seconds = String(now.getSeconds()).padStart(2, "0");
      
      this.currentTime = `${day}, ${date} ${month} ${year} | ${hours}:${minutes}:${seconds}`;
    },
    toggleHamburgerMenu() {
      var windowSize = document.documentElement.clientWidth;
      let layoutType = document.documentElement.getAttribute("data-layout");
      document.documentElement.setAttribute("data-sidebar-visibility", "show");
      if (windowSize > 767) document.querySelector(".hamburger-icon").classList.toggle("open");
      if (layoutType === "vertical" || layoutType === "semibox") {
        if (windowSize < 1025 && windowSize > 767) {
          document.body.classList.remove("vertical-sidebar-enable");
          document.documentElement.getAttribute("data-sidebar-size") == "sm" ?
            document.documentElement.setAttribute("data-sidebar-size", "") :
            document.documentElement.setAttribute("data-sidebar-size", "sm");
        } else if (windowSize > 1025) {
          document.body.classList.remove("vertical-sidebar-enable");
          document.documentElement.getAttribute("data-sidebar-size") == "lg" ?
            document.documentElement.setAttribute("data-sidebar-size", "sm") :
            document.documentElement.setAttribute("data-sidebar-size", "lg");
        } else if (windowSize <= 767) {
          document.body.classList.add("vertical-sidebar-enable");
          document.documentElement.setAttribute("data-sidebar-size", "lg");
        }
      }
    },
    initFullScreen() {
      document.body.classList.toggle("fullscreen-enable");
      if (!document.fullscreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement) {
        if (document.documentElement.requestFullscreen) document.documentElement.requestFullscreen();
      } else {
        if (document.cancelFullScreen) document.cancelFullScreen();
        else if (document.mozCancelFullScreen) document.mozCancelFullScreen();
        else if (document.webkitCancelFullScreen) document.webkitCancelFullScreen();
      }
    },
    toggleDarkMode() {
      const currentMode = document.documentElement.getAttribute("data-bs-theme");
      const newMode = currentMode === "dark" ? "light" : "dark";
      document.documentElement.setAttribute("data-bs-theme", newMode);
      this.changeMode({ mode: newMode });
    },
  },
  mounted() {
    document.addEventListener("scroll", function () {
      var pageTopbar = document.getElementById("page-topbar");
      if (pageTopbar) {
        document.body.scrollTop >= 50 || document.documentElement.scrollTop >= 50 ? 
          pageTopbar.classList.add("topbar-shadow") : pageTopbar.classList.remove("topbar-shadow");
      }
    });
    if (document.getElementById("topnav-hamburger-icon"))
      document.getElementById("topnav-hamburger-icon").addEventListener("click", this.toggleHamburgerMenu);
    
    this.updateTime();
    this.timer = setInterval(this.updateTime, 1000);
  },
  beforeUnmount() {
    clearInterval(this.timer);
  },
};
</script>

<template>
  <header id="page-topbar">
    <div class="layout-width">
      <div class="navbar-header">
        <div class="d-flex align-items-center">
          <!-- LOGO -->
          <div class="navbar-brand-box horizontal-logo">
            <Link href="/" class="logo logo-dark">
              <span class="logo-sm"><img src="/images/logo_parkirgo.png" alt="" height="28" /></span>
              <span class="logo-lg"><img src="/images/logo_parkirgo.png" alt="" height="28" /></span>
            </Link>
            <Link href="/" class="logo logo-light">
              <span class="logo-sm"><img src="/images/logo_parkirgo.png" alt="" height="28" /></span>
              <span class="logo-lg"><img src="/images/logo_parkirgo.png" alt="" height="28" /></span>
            </Link>
          </div>

          <button type="button" class="btn btn-sm px-3 fs-16 header-item vertical-menu-btn topnav-hamburger shadow-none" id="topnav-hamburger-icon">
            <span class="hamburger-icon"><span></span><span></span><span></span></span>
          </button>

          <!-- Real-time Clock -->
          <div class="ms-3 d-none d-md-flex align-items-center text-dark fw-bold">
            <i class="ri-time-line me-2 fs-18 text-primary"></i>
            <span class="fs-15">{{ currentTime }}</span>
          </div>
        </div>

        <div class="d-flex align-items-center">
          <div class="ms-1 header-item d-none d-sm-flex">
            <BButton type="button" variant="ghost-secondary" class="btn-icon btn-topbar rounded-circle shadow-none" @click="initFullScreen">
              <i class="bx bx-fullscreen fs-22"></i>
            </BButton>
          </div>

          <div class="ms-1 header-item d-none d-sm-flex">
            <BButton type="button" variant="ghost-secondary" class="btn-icon btn-topbar rounded-circle light-dark-mode shadow-none" @click="toggleDarkMode">
              <i class="bx bx-moon fs-22"></i>
            </BButton>
          </div>

          <BDropdown variant="link" class="ms-sm-3 header-item topbar-user" toggle-class="rounded-circle arrow-none shadow-none" menu-class="dropdown-menu-end" :offset="{ alignmentAxis: -14, crossAxis: 0, mainAxis: 0 }">
            <template #button-content>
              <span class="d-flex align-items-center">
                <img class="rounded-circle header-profile-user" :src="$page.props.auth.user.profile_photo_url" :alt="$page.props.auth.user.name">
                <span class="text-start ms-xl-2">
                  <span class="d-none d-xl-inline-block ms-1 fw-medium user-name-text">{{ $page.props.auth.user.name }}</span>
                  <span class="d-none d-xl-block ms-1 fs-12 user-name-sub-text text-capitalize">{{ $page.props.auth.user.role }}</span>
                </span>
              </span>
            </template>
            <h6 class="dropdown-header">Selamat Datang, {{ $page.props.auth.user.name }}!</h6>
            
            <Link class="dropdown-item py-2" :href="route('profile.show')">
              <i class="mdi mdi-account-circle text-muted fs-16 align-middle me-1"></i>
              <span class="align-middle">Profil Saya</span>
            </Link>

            <Link class="dropdown-item py-2" href="/auth/lockscreen-basic">
              <i class="mdi mdi-lock text-muted fs-16 align-middle me-1"></i>
              <span class="align-middle">Kunci Layar</span>
            </Link>

            <div class="dropdown-divider"></div>
            
            <form method="POST" @submit.prevent="logout" class="p-0">
              <button type="submit" class="dropdown-item py-2 border-0 bg-transparent w-100 text-start text-danger fw-bold">
                <i class="mdi mdi-logout fs-16 align-middle me-1"></i> Keluar
              </button>
            </form>
          </BDropdown>
        </div>
      </div>
    </div>
  </header>
</template>
