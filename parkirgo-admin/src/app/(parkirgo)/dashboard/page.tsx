"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { Card, CardBody, CardHeader, Col, Row, Spinner } from "reactstrap";
import ReactApexChart from "react-apexcharts";

const DashboardPage = () => {
  const [loading, setLoading] = useState(true);
  const [dashboardData, setDashboardData] = useState<any>(null);
  const [selectedDate, setSelectedDate] = useState(
    new Date().toISOString().split("T")[0]
  );

  useEffect(() => {
    fetchDashboardData();
  }, [selectedDate]);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      const res = await fetch(`/api/dashboard?date=${selectedDate}`);
      const data = await res.json();
      if (data.success) {
        setDashboardData(data.data);
      }
    } catch (error) {
      console.error("Error fetching dashboard:", error);
    } finally {
      setLoading(false);
    }
  };

  // Chart options
  const weeklyChartOptions: any = {
    chart: {
      height: 280,
      type: "area",
      toolbar: {
        show: false,
      },
    },
    colors: ["#5664d2", "#22c55e"],
    dataLabels: {
      enabled: false,
    },
    stroke: {
      curve: "smooth",
      width: 2,
    },
    fill: {
      type: "gradient",
      gradient: {
        shadeIntensity: 1,
        opacityFrom: 0.3,
        opacityTo: 0.05,
        stops: [0, 90, 100],
      },
    },
    xaxis: {
      categories: dashboardData?.weeklyTrend?.map((d: any) => {
        const date = new Date(d.date);
        return date.toLocaleDateString("id-ID", { weekday: "short" });
      }) || [],
    },
    yaxis: {
      labels: {
        formatter: (val: number) => {
          return new Intl.NumberFormat("id-ID", {
            style: "currency",
            currency: "IDR",
            maximumFractionDigits: 0,
          }).format(val);
        },
      },
    },
    tooltip: {
      y: {
        formatter: (val: number) =>
          new Intl.NumberFormat("id-ID", {
            style: "currency",
            currency: "IDR",
            maximumFractionDigits: 0,
          }).format(val),
      },
    },
  };

  const weeklyChartSeries = [
    {
      name: "Pendapatan",
      data:
        dashboardData?.weeklyTrend?.map((d: any) => d.total) ||
        [0, 0, 0, 0, 0, 0, 0],
    },
  ];

  const paymentChartOptions: any = {
    chart: {
      type: "donut",
    },
    labels: ["Tunai", "QRIS"],
    colors: ["#5664d2", "#22c55e"],
    legend: {
      position: "bottom",
    },
    responsive: [
      {
        breakpoint: 480,
        options: {
          chart: {
            height: 200,
          },
          legend: {
            position: "bottom",
          },
        },
      },
    ],
    tooltip: {
      y: {
        formatter: (val: number) =>
          new Intl.NumberFormat("id-ID", {
            style: "currency",
            currency: "IDR",
            maximumFractionDigits: 0,
          }).format(val),
      },
    },
  };

  const paymentData = [
    dashboardData?.paymentBreakdown?.cash?._sum?.amount || 0,
    dashboardData?.paymentBreakdown?.qris?._sum?.amount || 0,
  ];

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      maximumFractionDigits: 0,
    }).format(amount);
  };

  return (
    <>
      <div className="page-content">
        <div className="container-fluid">
          {/* Page Title */}
          <div className="row">
            <div className="col-12">
              <div className="page-title-box d-flex align-items-center justify-content-between">
                <h4 className="mb-0 font-size-18">Dashboard ParkirGo</h4>
                <div className="page-title-right">
                  <input
                    type="date"
                    className="form-control form-control-sm"
                    style={{ width: "auto" }}
                    value={selectedDate}
                    onChange={(e) => setSelectedDate(e.target.value)}
                  />
                </div>
              </div>
            </div>
          </div>

          {loading ? (
            <div className="text-center py-5">
              <Spinner color="primary" />
              <p className="mt-2 text-muted">Memuat data dashboard...</p>
            </div>
          ) : (
            <>
              {/* Summary Cards */}
              <Row>
                <Col xl-3 md-6}>
                  <Card className="mini-stats-wid">
                    <CardBody>
                      <div className="d-flex">
                        <div className="flex-grow-1 overflow-hidden">
                          <p className="text-muted fw-medium text-truncate mb-0">
                            Pendapatan Hari Ini
                          </p>
                          <h4 className="mb-0 font-size-20 fw-semibold">
                            {formatCurrency(
                              dashboardData?.summary?.todayRevenue || 0
                            )}
                          </h4>
                        </div>
                        <div className="mini-stat-icon avatar-sm rounded-circle bg-primary align-self-center">
                          <span className="avatar-title bg-primary rounded-circle font-size-20">
                            <i className="ri-money-dollar-circle-line text-white"></i>
                          </span>
                        </div>
                      </div>
                    </CardBody>
                  </Card>
                </Col>

                <Col xl-3 md-6>
                  <Card className="mini-stats-wid">
                    <CardBody>
                      <div className="d-flex">
                        <div className="flex-grow-1 overflow-hidden">
                          <p className="text-muted fw-medium text-truncate mb-0">
                            Total Transaksi
                          </p>
                          <h4 className="mb-0 font-size-20 fw-semibold">
                            {dashboardData?.summary?.todayTransactions || 0}
                          </h4>
                        </div>
                        <div className="mini-stat-icon avatar-sm rounded-circle bg-success align-self-center">
                          <span className="avatar-title bg-success rounded-circle font-size-20">
                            <i className="ri-file-list-3-line text-white"></i>
                          </span>
                        </div>
                      </div>
                    </CardBody>
                  </Card>
                </Col>

                <Col xl-3 md-6>
                  <Card className="mini-stats-wid">
                    <CardBody>
                      <div className="d-flex">
                        <div className="flex-grow-1 overflow-hidden">
                          <p className="text-muted fw-medium text-truncate mb-0">
                            Kendaraan Aktif
                          </p>
                          <h4 className="mb-0 font-size-20 fw-semibold">
                            {dashboardData?.summary?.activeSessions || 0}
                          </h4>
                        </div>
                        <div className="mini-stat-icon avatar-sm rounded-circle bg-warning align-self-center">
                          <span className="avatar-title bg-warning rounded-circle font-size-20">
                            <i className="ri-car-line text-white"></i>
                          </span>
                        </div>
                      </div>
                    </CardBody>
                  </Card>
                </Col>

                <Col xl-3 md-6>
                  <Card className="mini-stats-wid">
                    <CardBody>
                      <div className="d-flex">
                        <div className="flex-grow-1 overflow-hidden">
                          <p className="text-muted fw-medium text-truncate mb-0">
                            Juru Parkir Aktif
                          </p>
                          <h4 className="mb-0 font-size-20 fw-semibold">
                            {dashboardData?.summary?.totalJukir || 0}
                          </h4>
                        </div>
                        <div className="mini-stat-icon avatar-sm rounded-circle bg-info align-self-center">
                          <span className="avatar-title bg-info rounded-circle font-size-20">
                            <i className="ri-user-location-line text-white"></i>
                          </span>
                        </div>
                      </div>
                    </CardBody>
                  </Card>
                </Col>
              </Row>

              {/* Charts */}
              <Row>
                <Col xl={8}>
                  <Card>
                    <CardHeader className="d-flex align-items-center">
                      <h5 className="mb-0">Tren Pendapatan Mingguan</h5>
                    </CardHeader>
                    <CardBody>
                      <ReactApexChart
                        options={weeklyChartOptions}
                        series={weeklyChartSeries}
                        type="area"
                        height={280}
                      />
                    </CardBody>
                  </Card>
                </Col>

                <Col xl={4}>
                  <Card>
                    <CardHeader className="d-flex align-items-center">
                      <h5 className="mb-0">Metode Pembayaran</h5>
                    </CardHeader>
                    <CardBody>
                      <ReactApexChart
                        options={paymentChartOptions}
                        series={paymentData}
                        type="donut"
                        height={280}
                      />
                    </CardBody>
                  </Card>
                </Col>
              </Row>

              {/* Top Zones */}
              <Row>
                <Col xl={12}>
                  <Card>
                    <CardHeader className="d-flex align-items-center justify-content-between">
                      <h5 className="mb-0">Performa Zona Parkir</h5>
                      <Link
                        href="/zona"
                        className="btn btn-sm btn-soft-secondary"
                      >
                        Lihat Semua
                        <i className="mdi mdi-arrow-right ms-1"></i>
                      </Link>
                    </CardHeader>
                    <CardBody>
                      <div className="table-responsive">
                        <table className="table table-hover align-middle mb-0">
                          <thead className="table-light">
                            <tr>
                              <th>Zona</th>
                              <th>Kota</th>
                              <th className="text-center">Total Kendaraan</th>
                              <th className="text-end">Total Pendapatan</th>
                            </tr>
                          </thead>
                          <tbody>
                            {dashboardData?.topZones?.length > 0 ? (
                              dashboardData.topZones.map((zone: any) => (
                                <tr key={zone.id}>
                                  <td>
                                    <Link
                                      href={`/zona/${zone.id}`}
                                      className="text-body fw-medium"
                                    >
                                      {zone.name}
                                    </Link>
                                  </td>
                                  <td>{zone.city || "-"}</td>
                                  <td className="text-center">
                                    {zone.totalVehicles}
                                  </td>
                                  <td className="text-end fw-semibold">
                                    {formatCurrency(zone.totalRevenue)}
                                  </td>
                                </tr>
                              ))
                            ) : (
                              <tr>
                                <td
                                  colSpan={4}
                                  className="text-center text-muted py-4"
                                >
                                  Tidak ada data zona
                                </td>
                              </tr>
                            )}
                          </tbody>
                        </table>
                      </div>
                    </CardBody>
                  </Card>
                </Col>
              </Row>

              {/* Quick Actions */}
              <Row className="mt-4">
                <Col xl={12}>
                  <Card>
                    <CardHeader>
                      <h5 className="mb-0">Aksi Cepat</h5>
                    </CardHeader>
                    <CardBody>
                      <div className="d-flex flex-wrap gap-2">
                        <Link
                          href="/zona/baru"
                          className="btn btn-outline-primary"
                        >
                          <i className="ri-add-circle-line me-1"></i>
                          Tambah Zona Baru
                        </Link>
                        <Link
                          href="/tarif/baru"
                          className="btn btn-outline-success"
                        >
                          <i className="ri-money-dollar-circle-line me-1"></i>
                          Atur Tarif Baru
                        </Link>
                        <Link
                          href="/pengguna/baru"
                          className="btn btn-outline-info"
                        >
                          <i className="ri-user-add-line me-1"></i>
                          Tambah Pengguna
                        </Link>
                        <Link
                          href="/laporan/harian"
                          className="btn btn-outline-warning"
                        >
                          <i className="ri-bar-chart-box-line me-1"></i>
                          Lihat Laporan
                        </Link>
                      </div>
                    </CardBody>
                  </Card>
                </Col>
              </Row>
            </>
          )}
        </div>
      </div>
    </>
  );
};

export default DashboardPage;