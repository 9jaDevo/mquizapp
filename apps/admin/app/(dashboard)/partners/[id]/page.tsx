'use client';

import { useEffect, useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import apiClient from '@/lib/api-client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { toast } from 'sonner';

interface PartnerDetail {
  id: number; orgName: string; orgType: string; email: string; phone?: string;
  plan: string; status: string; country?: string; website?: string;
  createdAt: string; approvedAt?: string;
  users: Array<{ id: number; email: string; role: string; status: string }>;
  contests: Array<{ id: number; title: string; status: string; createdAt: string; _count: { participants: number } }>;
}

interface Params { params: Promise<{ id: string }> }

export default function AdminPartnerDetailPage({ params }: Params) {
  const router = useRouter();
  const [partner, setPartner] = useState<PartnerDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [partnerId, setPartnerId] = useState(0);
  const [pending, startTransition] = useTransition();

  useEffect(() => {
    void params.then(({ id }) => {
      const pid = parseInt(id);
      setPartnerId(pid);
      void apiClient.get<PartnerDetail>(`/v2/admin/partners/${pid}`)
        .then((r) => setPartner(r.data))
        .finally(() => setLoading(false));
    });
  }, [params]);

  function action(fn: () => Promise<unknown>) {
    startTransition(() => { void fn().then(() => void apiClient.get<PartnerDetail>(`/v2/admin/partners/${partnerId}`).then((r) => setPartner(r.data))); });
  }

  async function approve() {
    await apiClient.post(`/v2/admin/partners/${partnerId}/approve`);
    toast.success('Partner approved');
  }
  async function suspend() {
    if (!confirm('Suspend this partner? All their tokens will be revoked.')) return;
    await apiClient.post(`/v2/admin/partners/${partnerId}/suspend`);
    toast.success('Partner suspended');
  }
  async function overridePlan(plan: string) {
    await apiClient.put(`/v2/admin/partners/${partnerId}/plan`, { plan });
    toast.success(`Plan changed to ${plan}`);
  }

  if (loading) return <div className="text-muted-foreground">Loading…</div>;
  if (!partner) return <div>Partner not found</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold">{partner.orgName}</h1>
          <div className="mt-1 flex gap-2">
            <Badge className="capitalize">{partner.plan}</Badge>
            <Badge variant={partner.status === 'active' ? 'default' : partner.status === 'suspended' ? 'destructive' : 'secondary'} className="capitalize">
              {partner.status}
            </Badge>
          </div>
        </div>
        <div className="flex gap-2">
          {partner.status === 'pending' && (
            <Button onClick={() => action(approve)} disabled={pending}>Approve</Button>
          )}
          {partner.status === 'active' && (
            <Button variant="destructive" onClick={() => action(suspend)} disabled={pending}>Suspend</Button>
          )}
          <Button variant="outline" onClick={() => router.back()}>Back</Button>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <div className="rounded-lg border p-4 space-y-2 text-sm">
          <h2 className="font-semibold">Organisation Info</h2>
          <Info label="Email" value={partner.email} />
          <Info label="Type" value={partner.orgType} />
          {partner.phone && <Info label="Phone" value={partner.phone} />}
          {partner.country && <Info label="Country" value={partner.country} />}
          {partner.website && <Info label="Website" value={partner.website} />}
          <Info label="Registered" value={new Date(partner.createdAt).toLocaleDateString()} />
          {partner.approvedAt && <Info label="Approved" value={new Date(partner.approvedAt).toLocaleDateString()} />}
        </div>

        <div className="rounded-lg border p-4 space-y-3">
          <h2 className="font-semibold text-sm">Override Plan</h2>
          <Select value={partner.plan} onValueChange={(v) => action(() => overridePlan(v))}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              {['free', 'starter', 'pro', 'enterprise'].map((p) => (
                <SelectItem key={p} value={p} className="capitalize">{p}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="rounded-lg border">
        <div className="border-b px-4 py-3 font-semibold text-sm">Team Members</div>
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              <th className="px-4 py-2 text-left">Email</th>
              <th className="px-4 py-2 text-left">Role</th>
              <th className="px-4 py-2 text-left">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {partner.users.map((u) => (
              <tr key={u.id} className="hover:bg-muted/25">
                <td className="px-4 py-2">{u.email}</td>
                <td className="px-4 py-2 capitalize">{u.role}</td>
                <td className="px-4 py-2 capitalize">{u.status}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="rounded-lg border">
        <div className="border-b px-4 py-3 font-semibold text-sm">Recent Contests</div>
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              <th className="px-4 py-2 text-left">Title</th>
              <th className="px-4 py-2 text-left">Status</th>
              <th className="px-4 py-2 text-left">Participants</th>
              <th className="px-4 py-2 text-left">Created</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {partner.contests.map((c) => (
              <tr key={c.id} className="hover:bg-muted/25">
                <td className="px-4 py-2 font-medium">{c.title}</td>
                <td className="px-4 py-2 capitalize">{c.status}</td>
                <td className="px-4 py-2">{c._count.participants}</td>
                <td className="px-4 py-2 text-xs text-muted-foreground">{new Date(c.createdAt).toLocaleDateString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Info({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between">
      <span className="text-muted-foreground">{label}</span>
      <span className="font-medium">{value}</span>
    </div>
  );
}
