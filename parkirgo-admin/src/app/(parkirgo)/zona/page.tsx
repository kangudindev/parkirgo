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

const ZonaPage = () => {
  const [zones, setZones] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [editData, setEditData] = useState<any>(null);
  const [formData, setFormData] = useState({
    name: "",
    city: "",
    capacity: "",
    qrisMerchantName: "",
  });
  const [saving, setSaving] = useState(false);
  const [alert, setAlert] = useState({ show: false, message: "", type: "" });

  useEffect(() => {
    fetchZones();
  }, []);

  const fetchZones = async () => {
    try {
      const res = await fetch("/api/zones");
      const data = await res.json();
      if (data.success) {
        setZones(data.data);
      }
    } catch (error) {
      console.error("Error fetching zones:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const url = editData
        ? `/api/zones/${editData.id}`
        : "/api/zones";
      const method = editData ? "PUT" : "POST";

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...formData,
          capacity: formData.capacity ? parseInt(formData.capacity) : null,
        }),
      });

      const data = await res.json();
      if (data.success) {
        setAlert({
          show: true,
          message: `Zona berhasil ${editData ? "diperbarui" : "dibuat"}`,
          type: "success",
        });
        setModal(false);
        setEditData(null);
        setFormData({ name: "", city: "", capacity: "", qrisMerchantName: "" });
        fetchZones();
      } else {
        setAlert({ show: true, message: data.error, type: "danger" });
      }
    } catch (error) {
      setAlert({ show: true, message: "Terjadi kesalahan", type: "danger" });
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (zone: any) => {
    setEditData(zone);
    setFormData({
      name: zone.name,
      city: zone.city || "",
      capacity: zone.capacity?.toString() || "",
      qrisMerchantName: zone.qrisMerchantName || "",
    });
    setModal(true);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Apakah Anda yakin ingin menghapus zona ini?")) return;

    try {
      const res = await fetch(`/api/zones/${id}`, { method: "DELETE" });
      const data = await res.json();
      if (data.success) {
        setAlert({ show: true, message: "Zona berhasil dihapus", type: "success" });
        fetchZones();
      } else {
        setAlert({ show: true, message: data.error, type: "danger" });
      }
    } catch (error) {
      setAlert({ show: true, message: "Terjadi kesalahan", type: "danger" });
    }
  };

  const openModal = () => {
    setEditData(null);
    setFormData({ name: "", city: "", capacity: "", qrisMerchantName: "" });
    setModal(true);
  };

  return (
    <div className="page-content">
      <div className="container-fluid">
        {/* Page Title */}
        <div className="row">
          <div className="col-12">
            <div className="page-title-box d-flex align-items-center justify-content-between">
              <h4 className="mb-0 font-size-18">Manajemen Zona Parkir</h4>
              <div className="page-title-right">
                <Button color="primary" onClick={openModal}>
                  <i className="ri-add-circle-line me-1"></i>
                  Tambah Zona Baru
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

        {/* Zones Table */}
        <Row>
          <Col xl={12}>
            <Card>
              <CardHeader>
                <h5 className="mb-0">Daftar Zona Parkir</h5>
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
                          <th>Nama Zona</th>
                          <th>Kota</th>
                          <th className="text-center">Kapasitas</th>
                          <th className="text-center">Jumlah Petugas</th>
                          <th className="text-center">Status</th>
                          <th className="text-center">Aksi</th>
                        </tr>
                      </thead>
                      <tbody>
                        {zones.length > 0 ? (
                          zones.map((zone) => (
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
                                {zone.capacity || "-"}
                              </td>
                              <td className="text-center">
                                {zone._count?.users || 0}
                              </td>
                              <td className="text-center">
                                <Badge
                                  color={zone.isActive ? "success" : "secondary"}
                                  pill
                                >
                                  {zone.isActive ? "Aktif" : "Nonaktif"}
                                </Badge>
                              </td>
                              <td className="text-center">
                                <Button
                                  color="btn btn-soft-primary btn-sm"
                                  onClick={() => handleEdit(zone)}
                                  style={{ padding: "4px 8px" }}
                                >
                                  <i className="ri-pencil-line"></i>
                                </Button>
                                <Button
                                  color="btn btn-soft-danger btn-sm ms-1"
                                  onClick={() => handleDelete(zone.id)}
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
                              colSpan={6}
                              className="text-center text-muted py-4"
                            >
                              Belum ada zona. Klik "Tambah Zona Baru" untuk
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

        {/* Modal Form */}
        <Modal isOpen={modal} toggle={() => setModal(false)}>
          <ModalHeader toggle={() => setModal(false)}>
            {editData ? "Edit Zona" : "Tambah Zona Baru"}
          </ModalHeader>
          <ModalBody>
            <Form>
              <FormGroup>
                <label className="form-label">Nama Zona *</label>
                <Input
                  type="text"
                  value={formData.name}
                  onChange={(e) =>
                    setFormData({ ...formData, name: e.target.value })
                  }
                  placeholder="Contoh: Zona Sudirman"
                  required
                />
              </FormGroup>
              <FormGroup>
                <label className="form-label">Kota</label>
                <Input
                  type="text"
                  value={formData.city}
                  onChange={(e) =>
                    setFormData({ ...formData, city: e.target.value })
                  }
                  placeholder="Contoh: Jakarta Selatan"
                />
              </FormGroup>
              <FormGroup>
                <label className="form-label">Kapasitas</label>
                <Input
                  type="number"
                  value={formData.capacity}
                  onChange={(e) =>
                    setFormData({ ...formData, capacity: e.target.value })
                  }
                  placeholder="Jumlah maksimal kendaraan"
                />
              </FormGroup>
              <FormGroup>
                <label className="form-label">Nama Merchant QRIS</label>
                <Input
                  type="text"
                  value={formData.qrisMerchantName}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      qrisMerchantName: e.target.value,
                    })
                  }
                  placeholder="Nama merchant untuk QRIS"
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

export default ZonaPage;