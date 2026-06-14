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
  Button,
  Input,
} from "reactstrap";

const AuditPage = () => {
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState({
    dateFrom: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
      .toISOString()
      .split("T")[0],
    dateTo: new Date().toISOString().split("T")[0],
    entityType: "",
    action: "",
  });
  const [pagination, setPagination] = useState({
    page: 1,
    totalPages: 1,
    total: 0,
  });

  useEffect(() => {
    fetchLogs();
  }, [filter, pagination.page]);

  const fetchLogs = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams({
        page: pagination.page.toString(),
        limit: "50",
        ...(filter.dateFrom && { dateFrom: filter.dateFrom }),
        ...(filter.dateTo && { dateTo: filter.dateTo }),
        ...(filter.entityType && { entityType: filter.entityType }),
        ...(filter.action && { action: filter.action }),
      });

      const res = await fetch(`/api/audit-logs?${params}`);
      const data = await res.json();
      if (data.success) {
        setLogs(data.data);
        setPagination((prev) => ({
          ...prev,
          totalPages: data.pagination.totalPages,
          total: data.pagination.total,
        }));
      }
    } catch (error) {
      console.error("Error fetching logs:", error);
    } finally {
      setLoading(false);
    }
  };

  const formatDateTime = (date: string) => {
    return new Date(date).toLocaleString("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
  };

  const getActionBadgeColor = (action: string) => {
    if (action.includes("DELETE")) return "danger";
    if (action.includes("CREATE")) return "success";
    if (action.includes("UPDATE")) return "primary";
    if (action.includes("VERIFY")) return "info";
    if (action.includes("REJECT")) return "warning";
    return "secondary";
  };

  return (
    <div className="page-content">
      <div className="container-fluid">
        <div className="row">
          <div className="col-12">
            <div className="page-title-box">
              <h4 className="mb-0 font-size-18">Log Audit Sistem</h4>
            </div>
          </div>
        </div>

        {/* Filters */}
        <Row className="mb-3">
          <Col md={2}>
            <Input
              type="date"
              value={filter.dateFrom}
              onChange={(e) =>
                setFilter({ ...filter, dateFrom: e.target.value })
              }
              placeholder="Dari Tanggal"
            />
          </Col>
          <Col md={2}>
            <Input
              type="date"
              value={filter.dateTo}
              onChange={(e) =>
                setFilter({ ...filter, dateTo: e.target.value })
              }
              placeholder="Sampai Tanggal"
            />
          </Col>
          <Col md={2}>
            <Input
              type="select"
              value={filter.entityType}
              onChange={(e) =>
                setFilter({ ...filter, entityType: e.target.value })
              }
            >
              <option value="">Semua Entitas</option>
              <option value="User">Pengguna</option>
              <option value="Zone">Zona</option>
              <option value="ZoneTariff">Tarif</option>
              <option value="ZonePenalty">Denda</option>
              <option value="Transaction">Transaksi</option>
            </Input>
          </Col>
          <Col md={2}>
            <Input
              type="select"
              value={filter.action}
              onChange={(e) =>
                setFilter({ ...filter, action: e.target.value })
              }
            >
              <option value="">Semua Aksi</option>
              <option value="CREATE">Buat</option>
              <option value="UPDATE">Ubah</option>
              <option value="DELETE">Hapus</option>
              <option value="VERIFY_TRANSACTION">Verifikasi</option>
              <option value="REJECT_TRANSACTION">Tolak</option>
              <option value="RESET_PASSWORD">Reset Password</option>
            </Input>
          </Col>
        </Row>

        <Row>
          <Col xl={12}>
            <Card>
              <CardHeader className="d-flex justify-content-between align-items-center">
                <h5 className="mb-0">
                  Riwayat Aktivitas ({pagination.total} aktivitas)
                </h5>
              </CardHeader>
              <CardBody>
                {loading ? (
                  <div className="text-center py-5">
                    <Spinner color="primary" />
                  </div>
                ) : (
                  <div className="table-responsive">
                    <Table className="table table-hover align-middle mb-0">
                      <thead className="table-light">
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
                        {logs.length > 0 ? (
                          logs.map((log) => (
                            <tr key={log.id}>
                              <td>{formatDateTime(log.createdAt)}</td>
                              <td>{log.user?.name || "System"}</td>
                              <td>
                                <span
                                  className={`badge bg-${getActionBadgeColor(
                                    log.action
                                  )}`}
                                >
                                  {log.action}
                                </span>
                              </td>
                              <td>{log.entityType}</td>
                              <td className="text-muted font-size-12">
                                {log.entityId?.substring(0, 8)}...
                              </td>
                              <td className="text-muted font-size-12">
                                {log.ipAddress || "-"}
                              </td>
                            </tr>
                          ))
                        ) : (
                          <tr>
                            <td
                              colSpan={6}
                              className="text-center text-muted py-4"
                            >
                              Tidak ada aktivitas dalam periode ini.
                            </td>
                          </tr>
                        )}
                      </tbody>
                    </Table>
                  </div>
                )}

                {/* Pagination */}
                {pagination.totalPages > 1 && (
                  <div className="d-flex justify-content-between align-items-center mt-3">
                    <div>
                      Halaman {pagination.page} dari {pagination.totalPages}
                    </div>
                    <div className="d-flex gap-2">
                      <Button
                        color="secondary"
                        size="sm"
                        disabled={pagination.page === 1}
                        onClick={() =>
                          setPagination({ ...pagination, page: 1 })
                        }
                      >
                        First
                      </Button>
                      <Button
                        color="secondary"
                        size="sm"
                        disabled={pagination.page === 1}
                        onClick={() =>
                          setPagination({
                            ...pagination,
                            page: pagination.page - 1,
                          })
                        }
                      >
                        Prev
                      </Button>
                      <Button
                        color="secondary"
                        size="sm"
                        disabled={
                          pagination.page === pagination.totalPages
                        }
                        onClick={() =>
                          setPagination({
                            ...pagination,
                            page: pagination.page + 1,
                          })
                        }
                      >
                        Next
                      </Button>
                    </div>
                  </div>
                )}
              </CardBody>
            </Card>
          </Col>
        </Row>
      </div>
    </div>
  );
};

export default AuditPage;