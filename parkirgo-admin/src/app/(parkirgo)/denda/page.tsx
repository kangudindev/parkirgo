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
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Form,
  FormGroup,
  Input,
  Alert,
} from "reactstrap";

const DendaPage = () => {
  const [penalties, setPenalties] = useState<any[]>([]);
  const [zones, setZones] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [editData, setEditData] = useState<any>(null);
  const [formData, setFormData] = useState({
    zoneId: "",
    vehicleType: "",
    penaltyType: "card_lost",
    amount: "",
  });
  const [saving, setSaving] = useState(false);
  const [alert, setAlert] = useState({ show: false, message: "", type: "" });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [penaltiesRes, zonesRes] = await Promise.all([
        fetch("/api/penalties"),
        fetch("/api/zones"),
      ]);
      const penaltiesData = await penaltiesRes.json();
      const zonesData = await zonesRes.json();
      if (penaltiesData.success) setPenalties(penaltiesData.data);
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
      const res = await fetch("/api/penalties", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...formData,
          amount: parseFloat(formData.amount),
          vehicleType: formData.vehicleType || null,
        }),
      });

      const data = await res.json();
      if (data.success) {
        setAlert({
          show: true,
          message: "Denda berhasil dibuat",
          type: "success",
        });
        setModal(false);
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

  const resetForm = () => {
    setFormData({
      zoneId: "",
      vehicleType: "",
      penaltyType: "card_lost",
      amount: "",
    });
    setEditData(null);
  };

  const openModal = () => {
    setEditData(null);
    resetForm();
    setModal(true);
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      maximumFractionDigits: 0,
    }).format(amount);
  };

  const getPenaltyTypeLabel = (type: string) => {
    return type === "card_lost" ? "Karcis Hilang" : "Tidak Tercatat";
  };

  const getVehicleTypeLabel = (type: string) => {
    if (!type) return "Semua Jenis";
    const labels: Record<string, string> = {
      motor: "Motor",
      mobil: "Mobil",
      bus: "Bus",
      truk: "Truk",
      other: "Lainnya",
    };
    return labels[type] || type;
  };

  return (
    <div className="page-content">
      <div className="container-fluid">
        <div className="row">
          <div className="col-12">
            <div className="page-title-box d-flex align-items-center justify-content-between">
              <h4 className="mb-0 font-size-18">Konfigurasi Denda</h4>
              <div className="page-title-right">
                <Button color="primary" onClick={openModal}>
                  <i className="ri-add-circle-line me-1"></i>
                  Tambah Denda Baru
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
                <h5 className="mb-0">Daftar Konfigurasi Denda</h5>
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
                          <th>Tipe Denda</th>
                          <th className="text-end">Nominal Denda</th>
                          <th className="text-center">Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {penalties.length > 0 ? (
                          penalties.map((penalty) => (
                            <tr key={penalty.id}>
                              <td className="fw-medium">
                                {penalty.zone?.name}
                              </td>
                              <td>{getVehicleTypeLabel(penalty.vehicleType)}</td>
                              <td>
                                <Badge
                                  color={
                                    penalty.penaltyType === "card_lost"
                                      ? "warning"
                                      : "danger"
                                  }
                                  pill
                                >
                                  {getPenaltyTypeLabel(penalty.penaltyType)}
                                </Badge>
                              </td>
                              <td className="text-end fw-semibold">
                                {formatCurrency(Number(penalty.amount))}
                              </td>
                              <td className="text-center">
                                <Badge
                                  color={
                                    penalty.status === "active"
                                      ? "success"
                                      : "secondary"
                                  }
                                  pill
                                >
                                  {penalty.status === "active"
                                    ? "Aktif"
                                    : "Nonaktif"}
                                </Badge>
                              </td>
                            </tr>
                          ))
                        ) : (
                          <tr>
                            <td
                              colSpan={5}
                              className="text-center text-muted py-4"
                            >
                              Belum ada konfigurasi denda.
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

        <Modal isOpen={modal} toggle={() => setModal(false)}>
          <ModalHeader toggle={() => setModal(false)}>
            Tambah Konfigurasi Denda
          </ModalHeader>
          <ModalBody>
            <Form>
              <FormGroup>
                <label className="form-label">Zona *</label>
                <Input
                  type="select"
                  value={formData.zoneId}
                  onChange={(e) =>
                    setFormData({ ...formData, zoneId: e.target.value })
                  }
                  required
                >
                  <option value="">-- Pilih Zona --</option>
                  {zones.map((zone) => (
                    <option key={zone.id} value={zone.id}>
                      {zone.name}
                    </option>
                  ))}
                </Input>
              </FormGroup>
              <FormGroup>
                <label className="form-label">Jenis Kendaraan</label>
                <Input
                  type="select"
                  value={formData.vehicleType}
                  onChange={(e) =>
                    setFormData({ ...formData, vehicleType: e.target.value })
                  }
                >
                  <option value="">Semua Jenis</option>
                  <option value="motor">Motor</option>
                  <option value="mobil">Mobil</option>
                  <option value="bus">Bus</option>
                  <option value="truk">Truk</option>
                </Input>
              </FormGroup>
              <FormGroup>
                <label className="form-label">Tipe Denda *</label>
                <Input
                  type="select"
                  value={formData.penaltyType}
                  onChange={(e) =>
                    setFormData({ ...formData, penaltyType: e.target.value })
                  }
                  required
                >
                  <option value="card_lost">Karcis Hilang</option>
                  <option value="unregistered">Tidak Tercatat</option>
                </Input>
              </FormGroup>
              <FormGroup>
                <label className="form-label">Nominal Denda (Rp) *</label>
                <Input
                  type="number"
                  value={formData.amount}
                  onChange={(e) =>
                    setFormData({ ...formData, amount: e.target.value })
                  }
                  placeholder="0"
                  required
                />
              </FormGroup>
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

export default DendaPage;