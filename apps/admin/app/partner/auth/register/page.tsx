'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { toast } from 'sonner';
import Link from 'next/link';

const ORG_TYPES = [
  { value: 'church', label: 'Church / Religious organisation' },
  { value: 'company', label: 'Company / Business' },
  { value: 'school', label: 'School / University' },
  { value: 'ngo', label: 'NGO / Non-profit' },
  { value: 'government', label: 'Government agency' },
  { value: 'individual', label: 'Individual' },
] as const;

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3000';

export default function PartnerRegisterPage() {
  const router = useRouter();
  const [form, setForm] = useState({ orgName: '', orgType: 'individual', email: '', password: '', phone: '', country: '' });
  const [loading, setLoading] = useState(false);

  function setField(field: string, value: string) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await fetch(`${API_URL}/v2/partner/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      const body = await res.json() as { success?: boolean; message?: string };
      if (!res.ok || !body.success) {
        toast.error(body.message ?? 'Registration failed');
        return;
      }
      toast.success('Registration successful! You can now sign in.');
      router.push('/partner/auth/login');
    } catch {
      toast.error('Network error — please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="w-full max-w-md space-y-6 rounded-xl border bg-card p-8 shadow-sm">
      <div className="text-center">
        <h1 className="text-2xl font-bold">Register as a Partner</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Host branded quiz competitions for your community
        </p>
      </div>
      <form onSubmit={(e) => { void handleSubmit(e); }} className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="orgName">Organisation Name</Label>
          <Input
            id="orgName"
            value={form.orgName}
            onChange={(e) => setField('orgName', e.target.value)}
            placeholder="e.g. Lagos Tech Community"
            required
            minLength={2}
            maxLength={255}
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="orgType">Organisation Type</Label>
          <Select value={form.orgType} onValueChange={(v) => setField('orgType', v)}>
            <SelectTrigger id="orgType">
              <SelectValue placeholder="Select type" />
            </SelectTrigger>
            <SelectContent>
              {ORG_TYPES.map((t) => (
                <SelectItem key={t.value} value={t.value}>
                  {t.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-2">
          <Label htmlFor="email">Email</Label>
          <Input
            id="email"
            type="email"
            value={form.email}
            onChange={(e) => setField('email', e.target.value)}
            placeholder="admin@yourorg.com"
            required
            autoComplete="email"
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="password">Password</Label>
          <Input
            id="password"
            type="password"
            value={form.password}
            onChange={(e) => setField('password', e.target.value)}
            placeholder="At least 8 characters"
            required
            minLength={6}
            maxLength={128}
            autoComplete="new-password"
          />
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div className="space-y-2">
            <Label htmlFor="phone">Phone (optional)</Label>
            <Input
              id="phone"
              type="tel"
              value={form.phone}
              onChange={(e) => setField('phone', e.target.value)}
              placeholder="+234…"
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="country">Country code</Label>
            <Input
              id="country"
              value={form.country}
              onChange={(e) => setField('country', e.target.value.toUpperCase())}
              placeholder="NG"
              maxLength={3}
            />
          </div>
        </div>
        <Button type="submit" className="w-full" disabled={loading}>
          {loading ? 'Creating account…' : 'Create Partner Account'}
        </Button>
      </form>
      <p className="text-center text-sm text-muted-foreground">
        Already have an account?{' '}
        <Link href="/partner/auth/login" className="underline hover:text-foreground">
          Sign in
        </Link>
      </p>
    </div>
  );
}
