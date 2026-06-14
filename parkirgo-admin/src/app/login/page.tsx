"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  Form,
  FormGroup,
  Input,
  Button,
  Spinner,
} from "reactstrap";

const LoginPage = () => {
  const router = useRouter();
  const [nik, setNik] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      const res = await fetch("/api/auth", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: "login", nik, password }),
      });

      const data = await res.json();

      if (data.success) {
        router.push("/dashboard");
      } else {
        setError(data.error || "Login gagal");
      }
    } catch (err) {
      setError("Terjadi kesalahan. Silakan coba lagi.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-wrapper">
      <div className="auth-bg">
        <span className="r"></span>
        <span className="r r4"></span>
        <span className="r r-sm"></span>
        <span className="r r-md"></span>
        <span className="r r-lg"></span>
      </div>
      <div className="auth-content">
        <div className="auth-logo text-center mb-4">
          <img
            src="/images/logo-parkirgo.png"
            alt="ParkirGo"
            style={{ height: "60px", marginBottom: "16px" }}
          />
          <p className="text-muted">Sistem Manajemen Parkir Tepi Jalan</p>
        </div>
        <div className="card">
          <div className="card-body">
            <div className="text-center">
              <h5 className="mb-4">Masuk ke Akun Anda</h5>
            </div>
            {error && (
              <div className="alert alert-danger" role="alert">
                {error}
              </div>
            )}
            <Form onSubmit={handleLogin}>
              <FormGroup>
                <label className="form-label">NIK</label>
                <Input
                  type="text"
                  className="form-control"
                  placeholder="Masukkan NIK"
                  value={nik}
                  onChange={(e) => setNik(e.target.value)}
                  required
                />
              </FormGroup>
              <FormGroup>
                <label className="form-label">Password</label>
                <Input
                  type="password"
                  className="form-control"
                  placeholder="Masukkan password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </FormGroup>
              <div className="d-grid">
                <Button
                  type="submit"
                  color="primary"
                  disabled={loading}
                  className="w-100"
                >
                  {loading ? (
                    <>
                      <Spinner size="sm" className="me-2" />
                      Memuat...
                    </>
                  ) : (
                    "Masuk"
                  )}
                </Button>
              </div>
            </Form>
          </div>
        </div>
        <div className="text-center mt-4">
          <p className="text-muted">
            &copy; {new Date().getFullYear()} ParkirGo. Hak cipta dilindungi.
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;