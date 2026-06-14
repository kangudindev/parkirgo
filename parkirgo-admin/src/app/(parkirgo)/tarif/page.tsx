"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
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
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Form,
  FormGroup,
  Input,
  Alert,
} from "reactstrap";

const TarifPage = () => {
  const [tariffs, setTariffs] = useState<any[]>([]);
  const [zones, setZones] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [editData, setEditData] = useState<any>(null);
  const [formData, setFormData] = useState({
    zoneId: "",
    vehicleType: "motor",
    pricingType: "progressive",
    paymentTiming: "exit",
    flatRate: "",
    progressiveRate: "",
    maxDaily: "",
    gracePeriodMinutes: "0",
  });
  const [saving, setSaving] = useState(false);
  const [alert, setAlert] = useState({ show: false, message: "", type: "" });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [tariffsRes, zonesRes] = await Promise.all([
        fetch("/api/tariffs"),
        fetch("/api/zones"),
      ]);
      const tariffsData = await tariffsRes.json();
      const zonesData = await zonesRes.json();
      if (tariffsData.success) setTariffs(tariffsData.data);
      if (zonesData.success) setZones(zonesData.data);
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const url = editData ? `/api/tariffs/${editData.id}` : "/api/tariffs";
      const method = editData ? "PUT" : "POST";

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...formData,
          flatRate: formData.flatRate ? parseFloat(formData.flatRate) : null,
          progressiveRate: formData.progressiveRate
            ? parseFloat(formData.progressiveRate)
            : null,
          maxDaily: formData.maxDaily ? parseFloat(formData.maxDaily) : null,
          gracePeriodMinutes: parseInt(formData.gracePeriodMinutes) || 0,
        }),
      });

      const data = await res.json();
      if (data.success) {
        setAlert({
          show: true,
          message: `Tarif berhasil ${editData ? "diperbarui" : "dibuat"}`,
          type: "success",
        });
        setModal(false);
        setEditData(null);
        resetForm();
        fetchData();
      } else {
        setAlert({ show: true, message: data.error, type: "danger" });
      }
    } catch (error) {
      setAlert({ show: true, message: "Terjadi kesalahan", type: "danger" });
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (tariff: any) => {
    setEditData(tariff);
    setFormData({
      zoneId: tariff.zoneId,
      vehicleType: tariff.vehicleType,
      pricingType: tariff.pricingType,
      paymentTiming: tariff.paymentTiming,
      flatRate: tariff.flatRate?.toString() || "",
      progressiveRate: tariff.progressiveRate?.toString() || "",
      maxDaily: tariff.maxDaily?.toString() || "",
      gracePeriodMinutes: tariff.gracePeriodMinutes?.toString() || "0",
    });
    setModal(true);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Apakah Anda yakin ingin menghapus tarif ini?")) return;

    try {
      const res = await fetch(`/api/tariffs/${id}`, { method: "DELETE" });
      const data = await res.json();
      if (data.success) {
        setAlert({ show: true, message: "Tarif berhasil dihapus", type: "success" });
        fetchData();
      } else {
        setAlert({ show: true, message: data.error, type: "danger" });
      }
    } catch (error) {
      setAlert({ show: true, message: "Terjadi kesalahan", type: "danger" });
    }
  };

  const resetForm = () => {
    setFormData({
      zoneId: "",
      vehicleType: "motor",
      pricingType: "progressive",
      paymentTiming: "exit",
      flatRate: "",
      progressiveRate: "",
      maxDaily: "",
      gracePeriodMinutes: "0",
    });
  };

  const openModal = () => {
    setEditData(null);
    resetForm();
    setModal(true);
  };

  const getVehicleTypeLabel = (type: string) => {
    const labels: Record<string, string> = {
      motor: "Motor",
      mobil: "Mobil",
      bus: "Bus",
      truk: "Truk",
      other: "Lainnya",
    };
    return labels[type] || type;
  };

  const formatCurrency = (amount: number | null) => {
    if (!amount) return "-";
    return new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      maximumFractionDigits: 0,
    }).format(amount);
  };

  return (
    <div className="page-content">
      <div className="container-fluid">
        <div className="row">
          <div className="col-12">
            <div className="page-title-box d-flex align-items-center justify-content-between">
              <h4 className="mb-0 font-size-18">Manajemen Tarif Parkir</h4>
              <div className="page-title-right">
                <Button color="primary" onClick={openModal}>
                  <i className="ri-add-circle-line me-1"></i>
                  Tambah Tarif Baru
                </Button>
              </div>
            </div>
          </div>
        </div>

        {alert.show && (
          <Alert
            color={alert.type}
            toggle={() => setAlert({ ...alert, show: false })}
          >
            {alert.message}
          </Alert>
        )}

        <Row>
          <Col xl={12}>
            <Card>
              <CardHeader>
                <h5 className="mb-0">Daftar Tarif Parkir</h5>
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
                          <th>Zona</th>
                          <th>Jenis Kendaraan</th>
                          <th>Tipe Tarif</th>
                          <th>Waktu Bayar</th>
                          <th className="text-end">Tarif</th>
                          <th className="text-end">Maks/Hari</th>
                          <th className="text-center">Status</th>
                          <th className="text-center">Aksi</th>
                        </tr>
                      </thead>
                      <tbody>
                        {tariffs.length > 0 ? (
                          tariffs.map((tariff) => (
                            <tr key={tariff.id}>
                              <td className="fw-medium">
                                {tariff.zone?.name}
                              </td>
                              <td>{getVehicleTypeLabel(tariff.vehicleType)}</td>
                              <td>
                                <Badge
                                  color={
                                    tariff.pricingType === "flat"
                                      ? "primary"
                                      : "success"
                                  }
                                  pill
                                >
                                  {tariff.pricingType === "flat"
                                    ? "Flat"
                                    : "Progresif"}
                                </Badge>
                              </td>
                              <td>
                                {tariff.paymentTiming === "entry"
                                  ? "Saat Masuk"
                                  : "Saat Keluar"}
                              </td>
                              <td className="text-end">
                                {tariff.pricingType === "flat"
                                  ? formatCurrency(tariff.flatRate)
                                  : `${formatCurrency(tariff.progressiveRate)}/jam`}
                              </td>
                              <td className="text-end">
                                {formatCurrency(tariff.maxDaily)}
                              </td>
                              <td className="text-center">
                                <Badge
                                  color={tariff.isActive ? "success" : "secondary"}
                                  pill
                                >
                                  {tariff.isActive ? "Aktif" : "Nonaktif"}
                                </Badge>
                              </td>
                              <td className="text-center">
                                <Button
                                  color="btn btn-soft-primary btn-sm"
                                  onClick={() => handleEdit(tariff)}
                                  style={{ padding: "4px 8px" }}
                                >
                                  <i className="ri-pencil-line"></i>
                                </Button>
                                <Button
                                  color="btn btn-soft-danger btn-sm ms-1"
                                  onClick={() => handleDelete(tariff.id)}
                                  style={{ padding: "4px 8px" }}
                                >
                                  <i className="ri-delete-bin-line"></i>
                                </Button>
                              </td>
                            </tr>
                          ))
                        ) : (
                          <tr>
                            <td
                              colSpan={8}
                              className="text-center text-muted py-4"
                            >
                              Belum ada tarif. Klik "Tambah Tarif Baru" untuk
                              memulai.
                            </td>
                          </tr>
                        )}
                      </tbody>
                    </Table>
                  </div>
                )}
              </CardBody>
            </Card>
          </Col>
        </Row>

        <Modal isOpen={modal} toggle={() => setModal(false)} size="lg">
          <ModalHeader toggle={() => setModal(false)}>
            {editData ? "Edit Tarif" : "Tambah Tarif Baru"}
          </ModalHeader>
          <ModalBody>
            <Form>
              <Row>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">Zona *</label>
                    <Input
                      type="select"
                      value={formData.zoneId}
                      onChange={(e) =>
                        setFormData({ ...formData, zoneId: e.target.value })
                      }
                      required
                      disabled={!!editData}
                    >
                      <option value="">-- Pilih Zona --</option>
                      {zones.map((zone) => (
                        <option key={zone.id} value={zone.id}>
                          {zone.name}
                        </option>
                      ))}
                    </Input>
                  </FormGroup>
                </Col>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">Jenis Kendaraan *</label>
                    <Input
                      type="select"
                      value={formData.vehicleType}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          vehicleType: e.target.value,
                        })
                      }
                      required
                      disabled={!!editData}
                    >
                      <option value="motor">Motor</option>
                      <option value="mobil">Mobil</option>
                      <option value="bus">Bus</option>
                      <option value="truk">Truk</option>
                      <option value="other">Lainnya</option>
                    </Input>
                  </FormGroup>
                </Col>
              </Row>
              <Row>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">Tipe Tarif *</label>
                    <Input
                      type="select"
                      value={formData.pricingType}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          pricingType: e.target.value,
                        })
                      }
                      required
                    >
                      <option value="progressive">Progresif (per jam)</option>
                      <option value="flat">Flat (tarif tetap)</option>
                    </Input>
                  </FormGroup>
                </Col>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">Waktu Pembayaran *</label>
                    <Input
                      type="select"
                      value={formData.paymentTiming}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          paymentTiming: e.target.value,
                        })
                      }
                      required
                    >
                      <option value="exit">Saat Kendaraan Keluar</option>
                      <option value="entry">Saat Kendaraan Masuk</option>
                    </Input>
                  </FormGroup>
                </Col>
              </Row>
              <Row>
                <Col md={4}>
                  <FormGroup>
                    <label className="form-label">
                      {formData.pricingType === "flat"
                        ? "Tarif (Rp)"
                        : "Tarif/Jam (Rp)"}
                    </label>
                    <Input
                      type="number"
                      value={
                        formData.pricingType === "flat"
                          ? formData.flatRate
                          : formData.progressiveRate
                      }
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          [formData.pricingType === "flat"
                            ? "flatRate"
                            : "progressiveRate"]: e.target.value,
                        })
                      }
                      placeholder="0"
                    />
                  </FormGroup>
                </Col>
                <Col md={4}>
                  <FormGroup>
                    <label className="form-label">Maksimum/Hari (Rp)</label>
                    <Input
                      type="number"
                      value={formData.maxDaily}
                      onChange={(e) =>
                        setFormData({ ...formData, maxDaily: e.target.value })
                      }
                      placeholder="0"
                    />
                  </FormGroup>
                </Col>
                <Col md={4}>
                  <FormGroup>
                    <label className="form-label">Grace Period (menit)</label>
                    <Input
                      type="number"
                      value={formData.gracePeriodMinutes}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          gracePeriodMinutes: e.target.value,
                        })
                      }
                      placeholder="0"
                    />
                  </FormGroup>
                </Col>
              </Row>
            </Form>
          </ModalBody>
          <ModalFooter>
            <Button color="secondary" onClick={() => setModal(false)}>
              Batal
            </Button>
            <Button color="primary" onClick={handleSave} disabled={saving}>
              {saving ? <Spinner size="sm" /> : ""} Simpan
            </Button>
          </ModalFooter>
        </Modal>
      </div>
    </div>
  );
};

export default TarifPage;