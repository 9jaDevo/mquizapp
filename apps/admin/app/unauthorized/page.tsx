import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function UnauthorizedPage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4">
      <h1 className="text-2xl font-bold">Access Denied</h1>
      <p className="text-muted-foreground">
        Your account does not have admin privileges.
      </p>
      <Button asChild variant="outline">
        <Link href="/login">Back to Login</Link>
      </Button>
    </div>
  );
}
