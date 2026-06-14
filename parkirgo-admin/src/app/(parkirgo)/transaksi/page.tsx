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
  Alert,
} from "reactstrap";

const TransaksiPage = () => {
  const [transactions, setTransactions] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState({
    dateFrom: new Date().toISOString().split("T")[0],
    dateTo: new Date().toISOString().split("T")[0],
    status: "",
    paymentMethod: "",
  });
  const [pagination, setPagination] = useState({
    page: 1,
    totalPages: 1,
    total: 0,
  });

  useEffect(() => {
    fetchTransactions();
  }, [filter]);

  const fetchTransactions = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams({
        page: pagination.page.toString(),
        limit: "20",
        ...(filter.dateFrom && { dateFrom: filter.dateFrom }),
        ...(filter.dateTo && { dateTo: filter.dateTo }),
        ...(filter.status && { status: filter.status }),
        ...(filter.paymentMethod && { paymentMethod: filter.paymentMethod }),
      });

      const res = await fetch(`/api/transactions?${params}`);
      const data = await res.json();
      if (data.success) {
        setTransactions(data.data);
        setPagination((prev) => ({
          ...prev,
          totalPages: data.pagination.totalPages,
          total: data.pagination.total,
        }));
      }
    } catch (error) {
      console.error("Error fetching transactions:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async (id: string, action: "verify" | "reject") => {
    try {
      const res = await fetch("/api/transactions", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ transactionId: id, action }),
      });
      const data = await res.json();
      if (data.success) {
        fetchTransactions();
      } else {
        alert(data.error);
      }
    } catch (error) {
      console.error("Error:", error);
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      maximumFractionDigits: 0,
    }).format(amount);
  };

  const formatDateTime = (date: string) => {
    return new Date(date).toLocaleString("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const getStatusBadge = (status: string) => {
    const badges: Record<string, { color: string; label: string }> = {
      recorded: { color: "warning", label: "Tercatat" },
      verified: { color: "success", label: "Terverifikasi" },
      rejected: { color: "danger", label: "Ditolak" },
      refunded: { color: "info", label: "Dikembalikan" },
    };
    return badges[status] || { color: "secondary", label: status };
  };

  const getPaymentMethodBadge = (method: string) => {
    return method === "cash" ? (
      <Badge color="primary" pill>
        Tunai
      </Badge>
    ) : (
      <Badge color="success" pill>
        QRIS
      </Badge>
    );
  };

  return (
    <div className="page-content">
      <div className="container-fluid">
        <div className="row">
          <div className="col-12">
            <div className="page-title-box">
              <h4 className="mb-0 font-size-18">Transaksi Parkir</h4>
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
              value={filter.paymentMethod}
              onChange={(e) =>
                setFilter({ ...filter, paymentMethod: e.target.value })
              }
            >
              <option value="">Semua Metode</option>
              <option value="cash">Tunai</option>
              <option value="qris_static">QRIS</option>
            </Input>
          </Col>
          <Col md={2}>
            <Input
              type="select"
              value={filter.status}
              onChange={(e) =>
                setFilter({ ...filter, status: e.target.value })
              }
            >
              <option value="">Semua Status</option>
              <option value="recorded">Tercatat</option>
              <option value="verified">Terverifikasi</option>
              <option value="rejected">Ditolak</option>
            </Input>
          </Col>
        </Row>

        <Row>
          <Col xl={12}>
            <Card>
              <CardHeader className="d-flex justify-content-between align-items-center">
                <h5 className="mb-0">
                  Daftar Transaksi ({pagination.total} transaksi)
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
                          <th>Plat Nomor</th>
                          <th>Zona</th>
                          <th>Petugas</th>
                          <th className="text-end">Jumlah</th>
                          <th>Metode</th>
                          <th>Status</th>
                          <th className="text-center">Aksi</th>
                        </tr>
                      </thead>
                      <tbody>
                        {transactions.length > 0 ? (
                          transactions.map((tx) => {
                            const statusBadge = getStatusBadge(
                              tx.paymentStatus
                            );
                            return (
                              <tr key={tx.id}>
                                <td>{formatDateTime(tx.transactionTime)}</td>
                                <td className="fw-medium">
                                  {tx.session?.vehiclePlate}
                                </td>
                                <td>{tx.session?.zone?.name || "-"}</td>
                                <td>
                                  {tx.shift?.user?.name || "-"}
                                </td>
                                <td className="text-end fw-semibold">
                                  {formatCurrency(Number(tx.amount))}
                                </td>
                                <td>{getPaymentMethodBadge(tx.paymentMethod)}</td>
                                <td>
                                  <Badge color={statusBadge.color} pill>
                                    {statusBadge.label}
                                  </Badge>
                                </td>
                                <td className="text-center">
                                  {tx.paymentStatus === "recorded" && (
                                    <>
                                      <Button
                                        color="btn btn-soft-success btn-sm"
                                        onClick={() =>
                                          handleVerify(tx.id, "verify")
                                        }
                                        style={{ padding: "4px 8px" }}
                                        title="Verifikasi"
                                      >
                                        <i className="ri-check-line"></i>
                                      </Button>
                                      <Button
                                        color="btn btn-soft-danger btn-sm ms-1"
                                        onClick={() =>
                                          handleVerify(tx.id, "reject")
                                        }
                                        style={{ padding: "4px 8px" }}
                                        title="Tolak"
                                      >
                                        <i className="ri-close-line"></i>
                                      </Button>
                                    </>
                                  )}
                                </td>
                              </tr>
                            );
                          })
                        ) : (
                          <tr>
                            <td
                              colSpan={8}
                              className="text-center text-muted py-4"
                            >
                              Tidak ada transaksi dalam periode ini.
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

export default TransaksiPage;