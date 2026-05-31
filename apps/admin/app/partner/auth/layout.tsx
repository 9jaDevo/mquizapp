/** Partner auth layout — no sidebar, centered card */
export default function PartnerAuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/40">
      {children}
    </div>
  );
}
