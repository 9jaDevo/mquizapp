'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { signIn } from 'next-auth/react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';
import Link from 'next/link';

export default function PartnerLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      const result = await signIn('partner-credentials', {
        email,
        password,
        redirect: false,
      });
      if (result?.error) {
        toast.error('Invalid email or password');
      } else {
        router.push('/partner/dashboard');
      }
    } catch {
      toast.error('Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="w-full max-w-sm space-y-6 rounded-xl border bg-card p-8 shadow-sm">
      <div className="text-center">
        <h1 className="text-2xl font-bold">Partner Portal</h1>
        <p className="mt-1 text-sm text-muted-foreground">Sign in to manage your contests</p>
      </div>
      <form onSubmit={(e) => { void handleSubmit(e); }} className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="email">Email</Label>
          <Input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@org.com"
            required
            autoComplete="email"
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="password">Password</Label>
          <Input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            required
            autoComplete="current-password"
          />
        </div>
        <Button type="submit" className="w-full" disabled={loading}>
          {loading ? 'Signing in…' : 'Sign In'}
        </Button>
      </form>
      <p className="text-center text-sm text-muted-foreground">
        No account?{' '}
        <Link href="/partner/auth/register" className="underline hover:text-foreground">
          Register your organisation
        </Link>
      </p>
    </div>
  );
}
