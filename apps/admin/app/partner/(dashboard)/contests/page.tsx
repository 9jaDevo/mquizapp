'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { partnerApi } from '@/lib/partner-api-client';
import { buttonVariants } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

interface Contest {
  id: number;
  title: string;
  status: string;
  visibility: string;
  maxParticipants: number;
  createdAt: string;
  _count?: { participants: number };
}

const STATUS_COLORS: Record<string, string> = {
  draft: 'secondary',
  published: 'default',
  live: 'default',
  ended: 'outline',
  archived: 'outline',
};

export default function PartnerContestsPage() {
  const [contests, setContests] = useState<Contest[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    try {
      const res = await partnerApi.listContests() as { items: Contest[] };
      setContests(res.items ?? []);
    } catch {
      toast.error('Failed to load contests');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { void load(); }, []);

  async function handlePublish(id: number) {
    try {
      await partnerApi.publishContest(id);
      toast.success('Contest published');
      void load();
    } catch (e) { toast.error((e as Error).message); }
  }

  async function handleEnd(id: number) {
    try {
      await partnerApi.endContest(id);
      toast.success('Contest ended');
      void load();
    } catch (e) { toast.error((e as Error).message); }
  }

  async function handleDelete(id: number) {
    if (!confirm('Delete this draft contest? This cannot be undone.')) return;
    try {
      await partnerApi.deleteContest(id);
      toast.success('Contest deleted');
      void load();
    } catch (e) { toast.error((e as Error).message); }
  }

  if (loading) return <div className="text-muted-foreground">Loading…</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold">Contests</h1>
          <p className="text-muted-foreground">Manage your hosted quiz competitions</p>
        </div>
        <Link href="/partner/contests/new" className={buttonVariants()}>+ New Contest</Link>
      </div>

      {contests.length === 0 ? (
        <div className="rounded-lg border border-dashed p-12 text-center text-muted-foreground">
          No contests yet.{' '}
          <Link href="/partner/contests/new" className="underline hover:text-foreground">Create your first contest</Link>
        </div>
      ) : (
        <div className="overflow-hidden rounded-lg border">
          <table className="w-full text-sm">
            <thead className="bg-muted/50">
              <tr>
                <th className="px-4 py-3 text-left font-medium">Title</th>
                <th className="px-4 py-3 text-left font-medium">Status</th>
                <th className="px-4 py-3 text-left font-medium">Visibility</th>
                <th className="px-4 py-3 text-left font-medium">Participants</th>
                <th className="px-4 py-3 text-left font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {contests.map((c) => (
                <tr key={c.id} className="hover:bg-muted/25">
                  <td className="px-4 py-3">
                    <Link href={`/partner/contests/${c.id}`} className="font-medium hover:underline">
                      {c.title}
                    </Link>
                  </td>
                  <td className="px-4 py-3">
                    <Badge variant={(STATUS_COLORS[c.status] as 'secondary' | 'default' | 'outline') ?? 'secondary'}>
                      {c.status}
                    </Badge>
                  </td>
                  <td className="px-4 py-3 capitalize">{c.visibility}</td>
                  <td className="px-4 py-3">{c._count?.participants ?? 0} / {c.maxParticipants}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-2">
                      <Link href={`/partner/contests/${c.id}`} className={buttonVariants({ variant: 'outline', size: 'sm' })}>
                        Edit
                      </Link>
                      {c.status === 'draft' && (
                        <Button size="sm" onClick={() => void handlePublish(c.id)}>Publish</Button>
                      )}
                      {(c.status === 'published' || c.status === 'live') && (
                        <Button size="sm" variant="outline" onClick={() => void handleEnd(c.id)}>End</Button>
                      )}
                      {c.status === 'draft' && (
                        <Button size="sm" variant="destructive" onClick={() => void handleDelete(c.id)}>Delete</Button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
