"use client";

import React, { useEffect, useState } from "react";
import {
  Card,
  CardBody,
  CardHeader,
  Col,
  Row,
  Table,
  Spinner,
  Badge,
  Button,
  Input,
} from "reactstrap";

const LaporanHarianPage = () => {
  const [reportData, setReportData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState({
    date: new Date().toISOString().split("T")[0],
  });

  useEffect(() => {
    fetchReport();
  }, [filter.date]);

  const fetchReport = async () => {
    try {
      setLoading(true);
      const res = await fetch(
        `/api/reports?type=daily&dateFrom=${filter.date}&dateTo=${filter.date}`
      );
      const data = await res.json();
      if (data.success) {
        setReportData(data.data);
      }
    } catch (error) {
      console.error("Error fetching report:", error);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      maximumFractionDigits: 0,
    }).format(amount);
  };

  const handleExport = () => {
    alert("Fitur export akan segera hadir");
  };

  return (
    <div className="page-content">
      <div className="container-fluid">
        <div className="row">
          <div className="col-12">
            <div className="page-title-box d-flex align-items-center justify-content-between">
              <h4 className="mb-0 font-size-18">Laporan Harian</h4>
              <div className="d-flex gap-2">
                <Input
                  type="date"
                  value={filter.date}
                  onChange={(e) =>
                    setFilter({ ...filter, date: e.target.value })
                  }
                  style={{ width: "auto" }}
                />
                <Button color="success" onClick={handleExport}>
                  <i className="ri-file-excel-line me-1"></i>
                  Export Excel
                </Button>
              </div>
            </div>
          </div>
        </div>

        {loading ? (
          <div className="text-center py-5">
            <Spinner color="primary" />
          </div>
        ) : reportData ? (
          <>
            {/* Summary Cards */}
            <Row className="mb-4">
              <Col md={4}>
                <Card className="mini-stats-wid">
                  <CardBody>
                    <div className="d-flex">
                      <div className="flex-grow-1">
                        <p className="text-muted fw-medium mb-0">
                          Total Transaksi
                        </p>
                        <h4 className="mb-0">
                          {reportData.summary.totalTransactions}
                        </h4>
                      </div>
                    </div>
                  </CardBody>
                </Card>
              </Col>
              <Col md={4}>
                <Card className="mini-stats-wid">
                  <CardBody>
                    <div className="d-flex">
                      <div className="flex-grow-1">
                        <p className="text-muted fw-medium mb-0">
                          Total Pendapatan
                        </p>
                        <h4 className="mb-0 text-success">
                          {formatCurrency(reportData.summary.totalRevenue)}
                        </h4>
                      </div>
                    </div>
                  </CardBody>
                </Card>
              </Col>
              <Col md={4}>
                <Card className="mini-stats-wid">
                  <CardBody>
                    <div className="d-flex">
                      <div className="flex-grow-1">
                        <p className="text-muted fw-medium mb-0">
                          Pendapatan Tunai
                        </p>
                        <h4 className="mb-0 text-primary">
                          {formatCurrency(
                            Number(
                              reportData.paymentBreakdown.cash.recorded?._sum
                                ?.amount || 0
                            ) +
                              Number(
                                reportData.paymentBreakdown.cash.verified?._sum
                                  ?.amount || 0
                              )
                          )}
                        </h4>
                      </div>
                    </div>
                  </CardBody>
                </Card>
              </Col>
            </Row>

            {/* Per Zone Breakdown */}
            <Row className="mb-4">
              <Col xl={12}>
                <Card>
                  <CardHeader>
                    <h5 className="mb-0">Rincian per Zona</h5>
                  </CardHeader>
                  <CardBody>
                    <div className="table-responsive">
                      <Table className="table table-hover align-middle mb-0">
                        <thead className="table-light">
                          <tr>
                            <th>Zona</th>
                            <th>Kota</th>
                            <th className="text-center">Jumlah Transaksi</th>
                            <th className="text-end">Total Pendapatan</th>
                          </tr>
                        </thead>
                        <tbody>
                          {reportData.zoneBreakdown?.length > 0 ? (
                            reportData.zoneBreakdown.map((zone: any) => (
                              <tr key={zone.zoneId}>
                                <td className="fw-medium">{zone.zoneName}</td>
                                <td>{zone.zoneCity || "-"}</td>
                                <td className="text-center">
                                  {zone.transactions}
                                </td>
                                <td className="text-end fw-semibold">
                                  {formatCurrency(zone.revenue)}
                                </td>
                              </tr>
                            ))
                          ) : (
                            <tr>
                              <td
                                colSpan={4}
                                className="text-center text-muted py-4"
                              >
                                Tidak ada data
                              </td>
                            </tr>
                          )}
                        </tbody>
                      </Table>
                    </div>
                  </CardBody>
                </Card>
              </Col>
            </Row>

            {/* Per Jukir Breakdown */}
            <Row>
              <Col xl={12}>
                <Card>
                  <CardHeader>
                    <h5 className="mb-0">Rincian per Juru Parkir</h5>
                  </CardHeader>
                  <CardBody>
                    <div className="table-responsive">
                      <Table className="table table-hover align-middle mb-0">
                        <thead className="table-light">
                          <tr>
                            <th>NIK</th>
                            <th>Nama Juru Parkir</th>
                            <th className="text-center">Jumlah Transaksi</th>
                            <th className="text-end">Total Pendapatan</th>
                          </tr>
                        </thead>
                        <tbody>
                          {reportData.jukirBreakdown?.length > 0 ? (
                            reportData.jukirBreakdown.map((jukir: any) => (
                              <tr key={jukir.shiftId}>
                                <td>{jukir.jukirNik || "-"}</td>
                                <td className="fw-medium">{jukir.jukirName}</td>
                                <td className="text-center">
                                  {jukir.transactions}
                                </td>
                                <td className="text-end fw-semibold">
                                  {formatCurrency(jukir.revenue)}
                                </td>
                              </tr>
                            ))
                          ) : (
                            <tr>
                              <td
                                colSpan={4}
                                className="text-center text-muted py-4"
                              >
                                Tidak ada data
                              </td>
                            </tr>
                          )}
                        </tbody>
                      </Table>
                    </div>
                  </CardBody>
                </Card>
              </Col>
            </Row>
          </>
        ) : (
          <div className="text-center py-5 text-muted">
            Tidak ada data laporan
          </div>
        )}
      </div>
    </div>
  );
};

export default LaporanHarianPage;