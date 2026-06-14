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

const PenggunaPage = () => {
  const [users, setUsers] = useState<any[]>([]);
  const [zones, setZones] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [editData, setEditData] = useState<any>(null);
  const [formData, setFormData] = useState({
    nik: "",
    name: "",
    email: "",
    phone: "",
    password: "",
    role: "jukir",
    zoneId: "",
  });
  const [saving, setSaving] = useState(false);
  const [alert, setAlert] = useState({ show: false, message: "", type: "" });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [usersRes, zonesRes] = await Promise.all([
        fetch("/api/users"),
        fetch("/api/zones"),
      ]);
      const usersData = await usersRes.json();
      const zonesData = await zonesRes.json();
      if (usersData.success) setUsers(usersData.data);
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
      const url = editData
        ? `/api/users/${editData.id}`
        : "/api/users";
      const method = editData ? "PUT" : "POST";

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      const data = await res.json();
      if (data.success) {
        setAlert({
          show: true,
          message: `Pengguna berhasil ${editData ? "diperbarui" : "dibuat"}`,
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

  const handleEdit = (user: any) => {
    setEditData(user);
    setFormData({
      nik: user.nik,
      name: user.name,
      email: user.email || "",
      phone: user.phone || "",
      password: "",
      role: user.role,
      zoneId: user.zoneId || "",
    });
    setModal(true);
  };

  const handleResetPassword = async (id: string) => {
    if (!confirm("Reset password ke default (123456)?")) return;

    try {
      const res = await fetch(`/api/users/${id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: "reset-password" }),
      });
      const data = await res.json();
      if (data.success) {
        setAlert({ show: true, message: data.message, type: "success" });
      } else {
        setAlert({ show: true, message: data.error, type: "danger" });
      }
    } catch (error) {
      setAlert({ show: true, message: "Terjadi kesalahan", type: "danger" });
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Apakah Anda yakin ingin menghapus pengguna ini?")) return;

    try {
      const res = await fetch(`/api/users/${id}`, { method: "DELETE" });
      const data = await res.json();
      if (data.success) {
        setAlert({ show: true, message: "Pengguna berhasil dihapus", type: "success" });
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
      nik: "",
      name: "",
      email: "",
      phone: "",
      password: "",
      role: "jukir",
      zoneId: "",
    });
  };

  const openModal = () => {
    setEditData(null);
    resetForm();
    setModal(true);
  };

  const getRoleBadge = (role: string) => {
    const badges: Record<string, { color: string; label: string }> = {
      admin: { color: "danger", label: "Admin" },
      supervisor: { color: "warning", label: "Supervisor" },
      jukir: { color: "info", label: "Juru Parkir" },
    };
    return badges[role] || { color: "secondary", label: role };
  };

  return (
    <div className="page-content">
      <div className="container-fluid">
        <div className="row">
          <div className="col-12">
            <div className="page-title-box d-flex align-items-center justify-content-between">
              <h4 className="mb-0 font-size-18">Manajemen Pengguna</h4>
              <div className="page-title-right">
                <Button color="primary" onClick={openModal}>
                  <i className="ri-user-add-line me-1"></i>
                  Tambah Pengguna Baru
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
                <h5 className="mb-0">Daftar Pengguna</h5>
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
                          <th>NIK</th>
                          <th>Nama</th>
                          <th>Role</th>
                          <th>Zona</th>
                          <th>Status</th>
                          <th className="text-center">Aksi</th>
                        </tr>
                      </thead>
                      <tbody>
                        {users.length > 0 ? (
                          users.map((user) => {
                            const roleBadge = getRoleBadge(user.role);
                            return (
                              <tr key={user.id}>
                                <td className="fw-medium">{user.nik}</td>
                                <td>{user.name}</td>
                                <td>
                                  <Badge color={roleBadge.color} pill>
                                    {roleBadge.label}
                                  </Badge>
                                </td>
                                <td>{user.zone?.name || "-"}</td>
                                <td>
                                  <Badge
                                    color={
                                      user.status === "active"
                                        ? "success"
                                        : "secondary"
                                    }
                                    pill
                                  >
                                    {user.status === "active"
                                      ? "Aktif"
                                      : "Nonaktif"}
                                  </Badge>
                                </td>
                                <td className="text-center">
                                  <Button
                                    color="btn btn-soft-primary btn-sm"
                                    onClick={() => handleEdit(user)}
                                    style={{ padding: "4px 8px" }}
                                  >
                                    <i className="ri-pencil-line"></i>
                                  </Button>
                                  <Button
                                    color="btn btn-soft-warning btn-sm ms-1"
                                    onClick={() => handleResetPassword(user.id)}
                                    style={{ padding: "4px 8px" }}
                                    title="Reset Password"
                                  >
                                    <i className="ri-lock-password-line"></i>
                                  </Button>
                                  <Button
                                    color="btn btn-soft-danger btn-sm ms-1"
                                    onClick={() => handleDelete(user.id)}
                                    style={{ padding: "4px 8px" }}
                                  >
                                    <i className="ri-delete-bin-line"></i>
                                  </Button>
                                </td>
                              </tr>
                            );
                          })
                        ) : (
                          <tr>
                            <td
                              colSpan={6}
                              className="text-center text-muted py-4"
                            >
                              Belum ada pengguna. Klik "Tambah Pengguna Baru"
                              untuk memulai.
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
            {editData ? "Edit Pengguna" : "Tambah Pengguna Baru"}
          </ModalHeader>
          <ModalBody>
            <Form>
              <Row>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">NIK *</label>
                    <Input
                      type="text"
                      value={formData.nik}
                      onChange={(e) =>
                        setFormData({ ...formData, nik: e.target.value })
                      }
                      placeholder="Nomor Induk Kependudukan"
                      required
                      disabled={!!editData}
                    />
                  </FormGroup>
                </Col>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">Nama Lengkap *</label>
                    <Input
                      type="text"
                      value={formData.name}
                      onChange={(e) =>
                        setFormData({ ...formData, name: e.target.value })
                      }
                      placeholder="Nama lengkap"
                      required
                    />
                  </FormGroup>
                </Col>
              </Row>
              <Row>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">Email</label>
                    <Input
                      type="email"
                      value={formData.email}
                      onChange={(e) =>
                        setFormData({ ...formData, email: e.target.value })
                      }
                      placeholder="email@contoh.com"
                    />
                  </FormGroup>
                </Col>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">No. Telepon</label>
                    <Input
                      type="text"
                      value={formData.phone}
                      onChange={(e) =>
                        setFormData({ ...formData, phone: e.target.value })
                      }
                      placeholder="08xxxxxxxxxx"
                    />
                  </FormGroup>
                </Col>
              </Row>
              <Row>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">Role *</label>
                    <Input
                      type="select"
                      value={formData.role}
                      onChange={(e) =>
                        setFormData({ ...formData, role: e.target.value })
                      }
                      required
                    >
                      <option value="jukir">Juru Parkir</option>
                      <option value="supervisor">Supervisor</option>
                      <option value="admin">Administrator</option>
                    </Input>
                  </FormGroup>
                </Col>
                <Col md={6}>
                  <FormGroup>
                    <label className="form-label">Zona</label>
                    <Input
                      type="select"
                      value={formData.zoneId}
                      onChange={(e) =>
                        setFormData({ ...formData, zoneId: e.target.value })
                      }
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
              </Row>
              {!editData && (
                <FormGroup>
                  <label className="form-label">Password *</label>
                  <Input
                    type="password"
                    value={formData.password}
                    onChange={(e) =>
                      setFormData({ ...formData, password: e.target.value })
                    }
                    placeholder="Password default: 123456"
                    required={!editData}
                  />
                  <small className="text-muted">
                    Password default adalah 123456
                  </small>
                </FormGroup>
              )}
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

export default PenggunaPage;