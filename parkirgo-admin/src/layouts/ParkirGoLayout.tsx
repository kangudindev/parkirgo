"use client";

import React, { useEffect, useCallback, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Collapse } from "reactstrap";
import navdata from "@/layouts/ParkirGoMenuData";
import { useTranslation } from "react-i18next";
import { useSelector } from "react-redux";
import { createSelector } from "reselect";

const ParkirGoLayout = (props: any) => {
  const navData = navdata().props.children;
  const pathname = usePathname();
  const router = useRouter();
  const { t } = useTranslation();
  
  // Auth state
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null);
  const [currentUser, setCurrentUser] = useState<any>(null);

  // Check authentication
  useEffect(() => {
    const checkAuth = async () => {
      try {
        const res = await fetch('/api/auth');
        const data = await res.json();
        if (data.authenticated) {
          setIsAuthenticated(true);
          setCurrentUser(data.user);
        } else {
          setIsAuthenticated(false);
          router.push('/login');
        }
      } catch {
        setIsAuthenticated(false);
        router.push('/login');
      }
    };
    checkAuth();
  }, [router]);

  // Layout settings
  const selectLayoutState = (state: any) => state.Layout;
  const selectLayoutProperties = createSelector(selectLayoutState, layout => ({
    leftsidbarSizeType: layout.leftsidbarSizeType,
    sidebarVisibilitytype: layout.sidebarVisibilitytype,
    layoutType: layout.layoutType,
  }));
  
  const { leftsidbarSizeType, sidebarVisibilitytype, layoutType } = useSelector(
    selectLayoutProperties
  );

  // Handle logout
  const handleLogout = async () => {
    try {
      await fetch('/api/auth', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'logout' }),
      });
      router.push('/login');
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  // Resize handler
  const resizeSidebarMenu = useCallback(() => {
    var windowSize = document.documentElement.clientWidth;
    const humberIcon = document.querySelector(".hamburger-icon") as HTMLElement;
    var hamburgerIcon = document.querySelector(".hamburger-icon");
    
    if (windowSize >= 1025) {
      if (document.documentElement.getAttribute("data-layout") === "vertical") {
        document.documentElement.setAttribute(
          "data-sidebar-size",
          leftsidbarSizeType
        );
      }
      if (
        (sidebarVisibilitytype === "show" ||
          layoutType === "vertical" ||
          layoutType === "twocolumn") &&
        document.querySelector(".hamburger-icon")
      ) {
        if (hamburgerIcon !== null) {
          hamburgerIcon.classList.remove("open");
        }
      } else {
        if (hamburgerIcon !== null) {
          hamburgerIcon.classList.add("open");
        }
      }
    } else if (windowSize < 1025 && windowSize > 767) {
      if (document.documentElement.getAttribute("data-layout") === "vertical") {
        document.documentElement.setAttribute("data-sidebar-size", "sm");
      }
      if (humberIcon) {
        humberIcon.classList.add("open");
      }
    } else if (windowSize <= 767) {
      document.body.classList.remove("vertical-sidebar-enable");
      if (document.documentElement.getAttribute("data-layout") !== "horizontal") {
        document.documentElement.setAttribute("data-sidebar-size", "lg");
      }
      if (humberIcon) {
        humberIcon.classList.add("open");
      }
    }
  }, [leftsidbarSizeType, sidebarVisibilitytype, layoutType]);

  useEffect(() => {
    window.addEventListener("resize", resizeSidebarMenu, true);
    return () => {
      window.removeEventListener("resize", resizeSidebarMenu, true);
    };
  }, [resizeSidebarMenu]);

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: "smooth" });
    const initMenu = () => {
      const ul = document.getElementById("navbar-nav") as HTMLElement;
      if (!ul) return;
      const items: any = ul.getElementsByTagName("a");
      let itemsArray = [...items];
      removeActivation(itemsArray);
      let matchingMenuItem = itemsArray.find(x => x.pathname === pathname);
      if (matchingMenuItem) {
        activateParentDropdown(matchingMenuItem);
      }
    };
    initMenu();
  }, [pathname]);

  function activateParentDropdown(item: any) {
    item.classList.add("active");
    let parentCollapseDiv = item.closest(".collapse.menu-dropdown");
    if (parentCollapseDiv) {
      parentCollapseDiv.classList.add("show");
      parentCollapseDiv.parentElement.children[0].classList.add("active");
      parentCollapseDiv.parentElement.children[0].setAttribute(
        "aria-expanded",
        "true"
      );
    }
    return false;
  }

  const removeActivation = (items: any) => {
    let actiItems = items.filter((x: any) => x.classList.contains("active"));
    actiItems.forEach((item: any) => {
      if (item.classList.contains("menu-link")) {
        if (!item.classList.contains("active")) {
          item.setAttribute("aria-expanded", false);
        }
        if (item.nextElementSibling) {
          item.nextElementSibling.classList.remove("show");
        }
      }
      if (item.classList.contains("nav-link")) {
        if (item.nextElementSibling) {
          item.nextElementSibling.classList.remove("show");
        }
        item.setAttribute("aria-expanded", false);
      }
      item.classList.remove("active");
    });
  };

  // Show loading while checking auth
  if (isAuthenticated === null) {
    return (
      <div className="auth-wrapper">
        <div className="auth-wrapper">
          <div className="spinner-border text-primary" role="status">
            <span className="sr-only">Memuat...</span>
          </div>
        </div>
      </div>
    );
  }

  // Don't render layout if not authenticated
  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="layout-wrapper">
      {/* Topbar */}
      <header id="page-topbar">
        <div className="navbar-header">
          <div className="d-flex">
            <button
              type="button"
              className="btn btn-sm px-3 font-size-24 d-lg-none header-item"
              data-toggle="collapse"
              onClick={() => {
                document.body.classList.toggle("vertical-sidebar-enable");
              }}
            >
              <i className="ri-menu-2-line align-middle"></i>
            </button>
            <Link href="/dashboard" className="header-item">
              <div className="d-flex align-items-center">
                <img
                  src="/images/logo-parkirgo.png"
                  alt="ParkirGo"
                  height="36"
                  className="me-2"
                />
              </div>
            </Link>
          </div>

          <div className="d-flex align-items-center">
            <div className="dropdown d-inline-block user-dropdown">
              <button
                type="button"
                className="btn header-item waves-effect"
                id="page-header-user-dropdown"
                data-bs-toggle="dropdown"
                aria-haspopup="true"
                aria-expanded="false"
              >
                <div className="d-flex align-items-center">
                  <div className="text-muted me-2">
                    <span className="d-block d-md-inline-block fw-medium">
                      {currentUser?.name || 'Admin'}
                    </span>
                    <span className="d-block d-md-inline-block font-size-12 text-muted">
                      {currentUser?.role === 'admin' ? 'Administrator' : currentUser?.role}
                    </span>
                  </div>
                </div>
              </button>
              <div className="dropdown-menu dropdown-menu-end">
                <button
                  className="dropdown-item d-block"
                  onClick={handleLogout}
                >
                  <i className="ri-shut-down-line align-middle me-1"></i>
                  <span>Keluar</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Sidebar */}
      <div className="vertical-menu">
        <div data-simplebar className="h-100">
          <div id="sidebar-menu">
            <ul className="navbar-nav" id="navbar-nav">
              {(navData || []).map((item: any, key: number) => {
                return (
                  <React.Fragment key={key}>
                    {item["isHeader"] ? (
                      <li className="menu-title">
                        <span>{t(item.label)}</span>
                      </li>
                    ) : item.subItems ? (
                      <li className="nav-item">
                        <Link
                          onClick={item.click}
                          className="nav-link menu-link"
                          href={item.link ? item.link : "#"}
                          data-bs-toggle="collapse"
                        >
                          <i className={item.icon}></i>
                          <span>{t(item.label)}</span>
                        </Link>
                        <Collapse
                          className="menu-dropdown"
                          isOpen={item.stateVariables}
                        >
                          <ul className="nav nav-sm flex-column">
                            {item.subItems &&
                              (item.subItems || []).map(
                                (subItem: any, subKey: number) => (
                                  <li className="nav-item" key={subKey}>
                                    <Link
                                      href={subItem.link ? subItem.link : "#"}
                                      className="nav-link"
                                    >
                                      {t(subItem.label)}
                                    </Link>
                                  </li>
                                )
                              )}
                          </ul>
                        </Collapse>
                      </li>
                    ) : (
                      <li className="nav-item">
                        <Link
                          className="nav-link menu-link"
                          href={item.link ? item.link : "#"}
                        >
                          <i className={item.icon}></i>
                          <span>{t(item.label)}</span>
                        </Link>
                      </li>
                    )}
                  </React.Fragment>
                );
              })}
            </ul>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="main-content">
        <div className="page-content">
          <div className="container-fluid">
            {props.children}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ParkirGoLayout;