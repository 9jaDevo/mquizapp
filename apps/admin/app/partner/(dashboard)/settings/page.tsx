'use client';

import { useEffect, useState } from 'react';
import { partnerApi } from '@/lib/partner-api-client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { toast } from 'sonner';

interface Profile { orgName: string; phone?: string; website?: string; description?: string; logoUrl?: string; country?: string; plan: string }

export default function PartnerSettingsPage() {
  const [form, setForm] = useState<Partial<Profile>>({});
  const [plan, setPlan] = useState('free');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    void partnerApi.getProfile().then((res) => {
      const p = res as Profile;
      setPlan(p.plan);
      setForm({ orgName: p.orgName, phone: p.phone ?? '', website: p.website ?? '', description: p.description ?? '', logoUrl: p.logoUrl ?? '', country: p.country ?? '' });
    }).finally(() => setLoading(false));
  }, []);

  function set(field: string, value: string) { setForm((prev) => ({ ...prev, [field]: value })); }

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      await partnerApi.updateProfile(form);
      toast.success('Profile updated');
    } catch (err) { toast.error((err as Error).message); }
    finally { setSaving(false); }
  }

  if (loading) return <div className="text-muted-foreground">Loading…</div>;

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Settings</h1>
        <p className="text-sm text-muted-foreground">Current plan: <span className="font-medium capitalize">{plan}</span></p>
      </div>
      <form onSubmit={(e) => { void handleSave(e); }} className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="orgName">Organisation Name</Label>
          <Input id="orgName" value={form.orgName ?? ''} onChange={(e) => set('orgName', e.target.value)} required />
        </div>
        <div className="space-y-2">
          <Label htmlFor="description">Description</Label>
          <Textarea id="description" value={form.description ?? ''} onChange={(e) => set('description', e.target.value)} rows={3} />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="phone">Phone</Label>
            <Input id="phone" value={form.phone ?? ''} onChange={(e) => set('phone', e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="country">Country Code</Label>
            <Input id="country" value={form.country ?? ''} onChange={(e) => set('country', e.target.value.toUpperCase())} maxLength={3} />
          </div>
        </div>
        <div className="space-y-2">
          <Label htmlFor="website">Website</Label>
          <Input id="website" type="url" value={form.website ?? ''} onChange={(e) => set('website', e.target.value)} placeholder="https://yourorg.com" />
        </div>
        <div className="space-y-2">
          <Label htmlFor="logoUrl">Logo URL</Label>
          <Input id="logoUrl" type="url" value={form.logoUrl ?? ''} onChange={(e) => set('logoUrl', e.target.value)} placeholder="https://…" />
        </div>
        <Button type="submit" disabled={saving}>{saving ? 'Saving…' : 'Save Changes'}</Button>
      </form>
    </div>
  );
}
