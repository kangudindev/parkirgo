import React, { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";

const Navdata = () => {
  const pathname = usePathname();
  
  // State for menu expansion
  const [isDashboard, setIsDashboard] = useState<boolean>(pathname === "/dashboard" || pathname === "/");
  const [isZona, setIsZona] = useState<boolean>(false);
  const [isTarif, setIsTarif] = useState<boolean>(false);
  const [isPengguna, setIsPengguna] = useState<boolean>(false);
  const [isDenda, setIsDenda] = useState<boolean>(false);
  const [isLaporan, setIsLaporan] = useState<boolean>(false);
  const [isAudit, setIsAudit] = useState<boolean>(false);

  const menuItems: any = [
    {
      label: "Menu Utama",
      isHeader: true,
    },
    {
      id: "dashboard",
      label: "Dashboard",
      icon: "ri-dashboard-2-line",
      link: "/dashboard",
      stateVariables: isDashboard,
      click: function (e: any) {
        e.preventDefault();
        setIsDashboard(!isDashboard);
      },
    },
    {
      id: "zona",
      label: "Manajemen Zona",
      icon: "ri-map-pin-3-line",
      link: "/#",
      stateVariables: isZona,
      click: function (e: any) {
        e.preventDefault();
        setIsZona(!isZona);
      },
      subItems: [
        {
          id: "zona-list",
          label: "Daftar Zona",
          link: "/zona",
          parentId: "zona",
        },
        {
          id: "zona-create",
          label: "Tambah Zona Baru",
          link: "/zona/baru",
          parentId: "zona",
        },
      ],
    },
    {
      id: "tarif",
      label: "Manajemen Tarif",
      icon: "ri-money-dollar-circle-line",
      link: "/#",
      stateVariables: isTarif,
      click: function (e: any) {
        e.preventDefault();
        setIsTarif(!isTarif);
      },
      subItems: [
        {
          id: "tarif-list",
          label: "Daftar Tarif",
          link: "/tarif",
          parentId: "tarif",
        },
        {
          id: "tarif-create",
          label: "Tambah Tarif Baru",
          link: "/tarif/baru",
          parentId: "tarif",
        },
      ],
    },
    {
      id: "pengguna",
      label: "Manajemen Pengguna",
      icon: "ri-user-settings-line",
      link: "/#",
      stateVariables: isPengguna,
      click: function (e: any) {
        e.preventDefault();
        setIsPengguna(!isPengguna);
      },
      subItems: [
        {
          id: "pengguna-list",
          label: "Daftar Pengguna",
          link: "/pengguna",
          parentId: "pengguna",
        },
        {
          id: "pengguna-create",
          label: "Tambah Pengguna Baru",
          link: "/pengguna/baru",
          parentId: "pengguna",
        },
      ],
    },
    {
      id: "denda",
      label: "Konfigurasi Denda",
      icon: "ri-error-warning-line",
      link: "/#",
      stateVariables: isDenda,
      click: function (e: any) {
        e.preventDefault();
        setIsDenda(!isDenda);
      },
      subItems: [
        {
          id: "denda-list",
          label: "Daftar Denda",
          link: "/denda",
          parentId: "denda",
        },
        {
          id: "denda-create",
          label: "Tambah Denda Baru",
          link: "/denda/baru",
          parentId: "denda",
        },
      ],
    },
    {
      id: "transaksi",
      label: "Transaksi",
      icon: "ri-file-list-3-line",
      link: "/transaksi",
      stateVariables: false,
    },
    {
      label: "Laporan & Audit",
      isHeader: true,
    },
    {
      id: "laporan",
      label: "Laporan",
      icon: "ri-bar-chart-box-line",
      link: "/#",
      stateVariables: isLaporan,
      click: function (e: any) {
        e.preventDefault();
        setIsLaporan(!isLaporan);
      },
      subItems: [
        {
          id: "laporan-harian",
          label: "Laporan Harian",
          link: "/laporan/harian",
          parentId: "laporan",
        },
        {
          id: "laporan-mingguan",
          label: "Laporan Mingguan",
          link: "/laporan/mingguan",
          parentId: "laporan",
        },
        {
          id: "laporan-bulanan",
          label: "Laporan Bulanan",
          link: "/laporan/bulanan",
          parentId: "laporan",
        },
      ],
    },
    {
      id: "audit",
      label: "Log Audit",
      icon: "ri-shield-check-line",
      link: "/audit",
      stateVariables: isAudit,
    },
  ];

  return <React.Fragment>{menuItems}</React.Fragment>;
};

export default Navdata;