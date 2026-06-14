import ParkirGoLayout from "@/layouts/ParkirGoLayout";

export default function ParkirGoRootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <ParkirGoLayout>{children}</ParkirGoLayout>;
}