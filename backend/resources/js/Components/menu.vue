<script>
import { Link, router } from '@inertiajs/vue3';
import { layoutComputed } from "@/state/helpers";
import simplebar from "simplebar-vue";

export default {
  components: {
    simplebar,
    Link
  },
  data() {
    return {
      settings: {
        minScrollbarLength: 60,
      },
    };
  },
  computed: {
    ...layoutComputed,
    layoutType: {
      get() {
        return this.$store ? this.$store.state.layout.layoutType : {} || {};
      },
    },
  },

  watch: {
    $route: {
      handler: "onRoutechange",
      immediate: true,
      deep: true,
    },
  },

  mounted() {
    this.initActiveMenu();
    if (this.rmenu == 'vertical' && this.layoutType == 'twocolumn') {
      document.documentElement.setAttribute("data-layout", "vertical");
    }
    document.getElementById('overlay').addEventListener('click', () => {
      document.body.classList.remove('vertical-sidebar-enable');
    });
    window.addEventListener("resize", () => {
      if (this.layoutType == 'twocolumn') {
        var windowSize = document.documentElement.clientWidth;
        if (windowSize < 767) {
          document.documentElement.setAttribute("data-layout", "vertical");
          this.rmenu = 'vertical';
          localStorage.setItem('rmenu', 'vertical');
        } else {
          document.documentElement.setAttribute("data-layout", "vertical");
          this.rmenu = 'twocolumn';
          localStorage.setItem('rmenu', 'twocolumn');
          setTimeout(() => {
            this.initActiveMenu();
    this.onRoutechange();
          }, 50);
        }
      }
    });
    this.onRoutechange();
    if (document.querySelectorAll(".navbar-nav .collapse")) {
      let collapses = document.querySelectorAll(".navbar-nav .collapse");

      collapses.forEach((collapse) => {
        // Hide sibling collapses on `show.bs.collapse`
        collapse.addEventListener("show.bs.collapse", (e) => {
          e.stopPropagation();
          let closestCollapse = collapse.parentElement.closest(".collapse");
          if (closestCollapse) {
            let siblingCollapses =
              closestCollapse.querySelectorAll(".collapse");
            siblingCollapses.forEach((siblingCollapse) => {
              if (siblingCollapse.classList.contains("show")) {
                siblingCollapse.classList.remove("show");
                siblingCollapse.parentElement.firstChild.setAttribute("aria-expanded", "false");
              }
            });
          } else {
            let getSiblings = (elem) => {
              // Setup siblings array and get the first sibling
              let siblings = [];
              let sibling = elem.parentNode.firstChild;
              // Loop through each sibling and push to the array
              while (sibling) {
                if (sibling.nodeType === 1 && sibling !== elem) {
                  siblings.push(sibling);
                }
                sibling = sibling.nextSibling;
              }
              return siblings;
            };
            let siblings = getSiblings(collapse.parentElement);
            siblings.forEach((item) => {
              if (item.childNodes.length > 2) {
                item.firstElementChild.setAttribute("aria-expanded", "false");
                item.firstElementChild.classList.remove("active");
              }
              let ids = item.querySelectorAll("*[id]");
              ids.forEach((item1) => {
                item1.classList.remove("show");
                item1.parentElement.firstChild.setAttribute("aria-expanded", "false");
                item1.parentElement.firstChild.classList.remove("active");
                if (item1.childNodes.length > 2) {
                  let val = item1.querySelectorAll("ul li a");

                  val.forEach((subitem) => {
                    if (subitem.hasAttribute("aria-expanded"))
                      subitem.setAttribute("aria-expanded", "false");
                  });
                }
              });
            });
          }
        });

        // Hide nested collapses on `hide.bs.collapse`
        collapse.addEventListener("hide.bs.collapse", (e) => {
          e.stopPropagation();
          let childCollapses = collapse.querySelectorAll(".collapse");
          childCollapses.forEach((childCollapse) => {
            let childCollapseInstance = childCollapse;
            childCollapseInstance.classList.remove("show");
            childCollapseInstance.parentElement.firstChild.setAttribute("aria-expanded", "false");
          });
        });
      });
    }
  },

  methods: {
    onRoutechange() {
      // this.initActiveMenu();
      setTimeout(() => {
        var currentPath = window.location.pathname;
        if (document.querySelector("#navbar-nav")) {
          let currentPosition = document.querySelector("#navbar-nav").querySelector('[href="' + currentPath + '"]')?.offsetTop;
          if (currentPosition > document.documentElement.clientHeight) {
            document.querySelector("#scrollbar .simplebar-content-wrapper") ? document.querySelector("#scrollbar .simplebar-content-wrapper").scrollTop = currentPosition + 300 : '';
          }
        }
      }, 500);
    },

    initActiveMenu() {
      setTimeout(() => {
        var currentPath = window.location.pathname;
        if (document.querySelector("#navbar-nav")) {
          let a = document.querySelector("#navbar-nav").querySelector('[href="' + currentPath + '"]');
          if (a) {
            a.classList.add("active");
            let parentCollapseDiv = a.closest(".collapse.menu-dropdown");
            if (parentCollapseDiv) {
              parentCollapseDiv.classList.add("show");
              parentCollapseDiv.parentElement.children[0].classList.add("active");
              parentCollapseDiv.parentElement.children[0].setAttribute("aria-expanded", "true");
              if (parentCollapseDiv.parentElement.closest(".collapse.menu-dropdown")) {
                parentCollapseDiv.parentElement.closest(".collapse").classList.add("show");
                if (parentCollapseDiv.parentElement.closest(".collapse").previousElementSibling)
                  parentCollapseDiv.parentElement.closest(".collapse").previousElementSibling.classList.add("active");
                const grandparent = parentCollapseDiv.parentElement.closest(".collapse").previousElementSibling.parentElement.closest(".collapse");
                if (grandparent && grandparent && grandparent.previousElementSibling) {
                  grandparent.previousElementSibling.classList.add("active");
                  grandparent.classList.add("show");
                }
              }
            }
          }
        }
      }, 0);
    },
  },
};
</script>

<template>
  <BContainer fluid>
    <div id="two-column-menu"></div>

    <template v-if="layoutType === 'vertical' || layoutType === 'semibox'">
      <ul class="navbar-nav h-100" id="navbar-nav">
        <li class="menu-title">
          <span data-key="t-parkirgo">ParkirGo</span>
        </li>
        <li class="nav-item">
          <Link href="/" class="nav-link menu-link" :class="{ active: $page.url === '/' }">
            <i class="ri-dashboard-3-line"></i>
            <span>Dashboard</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/zones" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/zones') }">
            <i class="ri-map-pin-2-line"></i>
            <span>Zona & Tarif</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/vehicle-types" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/vehicle-types') }">
            <i class="ri-roadster-line"></i>
            <span>Jenis Kendaraan</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/shifts" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/shifts') }">
            <i class="ri-calendar-line"></i>
            <span>Shift</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/penalties" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/penalties') }">
            <i class="ri-alert-line"></i>
            <span>Denda</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/operations" class="nav-link menu-link" :class="{ active: $page.url === '/parkirgo/operations' }">
            <i class="ri-parking-box-line"></i>
            <span>Operasional</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/attendances" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/attendances') }">
            <i class="ri-user-check-line"></i>
            <span>Absensi</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/finance" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/finance') }">
            <i class="ri-bank-card-line"></i>
            <span>Finance</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/users" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/users') }">
            <i class="ri-user-settings-line"></i>
            <span>Manajemen Pengguna</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/reports" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/reports') }">
            <i class="ri-bar-chart-2-line"></i>
            <span>Laporan</span>
          </Link>
        </li>
        <li class="nav-item">
          <Link href="/parkirgo/audit" class="nav-link menu-link" :class="{ active: $page.url.startsWith('/parkirgo/audit') }">
            <i class="ri-history-line"></i>
            <span>Audit Log</span>
          </Link>
        </li>
      </ul>
    </template>
  </BContainer>
</template>
