'use client';

import { useEffect, useState } from 'react';
import { partnerApi } from '@/lib/partner-api-client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import Link from 'next/link';
import { toast } from 'sonner';
import { buttonVariants } from '@/components/ui/button';
import { Copy, RefreshCw } from 'lucide-react';

interface Contest {
  id: number; title: string; description?: string; status: string; visibility: string;
  inviteCode?: string; maxParticipants: number; questionCount: number; timeLimitSeconds: number;
  prizeDescription?: string; startDate?: string; endDate?: string;
  _count?: { participants: number };
}

interface Params { params: Promise<{ id: string }> }

export default function ContestDetailPage({ params }: Params) {
  const [contest, setContest] = useState<Contest | null>(null);
  const [loading, setLoading] = useState(true);
  const [contestId, setContestId] = useState<number>(0);

  useEffect(() => {
    void params.then(({ id }) => {
      const cid = parseInt(id);
      setContestId(cid);
      partnerApi.getContest(cid).then((c) => setContest(c as Contest)).finally(() => setLoading(false));
    });
  }, [params]);

  async function handlePublish() {
    try { await partnerApi.publishContest(contestId); toast.success('Published!'); void reload(); }
    catch (e) { toast.error((e as Error).message); }
  }

  async function handleEnd() {
    try { await partnerApi.endContest(contestId); toast.success('Contest ended'); void reload(); }
    catch (e) { toast.error((e as Error).message); }
  }

  async function handleRegenCode() {
    try {
      const res = await partnerApi.regenerateCode(contestId) as { inviteCode: string };
      setContest((prev) => prev ? { ...prev, inviteCode: res.inviteCode } : prev);
      toast.success('New invite code generated');
    } catch (e) { toast.error((e as Error).message); }
  }

  async function reload() {
    const c = await partnerApi.getContest(contestId);
    setContest(c as Contest);
  }

  if (loading) return <div className="text-muted-foreground">Loading…</div>;
  if (!contest) return <div>Contest not found</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold">{contest.title}</h1>
          <div className="mt-1 flex gap-2">
            <Badge>{contest.status}</Badge>
            <Badge variant="outline" className="capitalize">{contest.visibility}</Badge>
          </div>
        </div>
        <div className="flex gap-2">
          {contest.status === 'draft' && <Button onClick={() => void handlePublish()}>Publish</Button>}
          {(contest.status === 'published' || contest.status === 'live') && (
            <Button variant="outline" onClick={() => void handleEnd()}>End Contest</Button>
          )}
        </div>
      </div>

      {contest.description && <p className="text-muted-foreground">{contest.description}</p>}

      <div className="grid gap-4 sm:grid-cols-3">
        <InfoCard label="Participants" value={`${contest._count?.participants ?? 0} / ${contest.maxParticipants}`} />
        <InfoCard label="Questions" value={contest.questionCount} />
        <InfoCard label="Time / Question" value={`${contest.timeLimitSeconds}s`} />
      </div>

      {contest.visibility === 'private' && contest.inviteCode && (
        <div className="flex items-center gap-3 rounded-lg border bg-muted/30 p-4">
          <div>
            <p className="text-xs text-muted-foreground">Invite Code</p>
            <p className="font-mono text-xl font-bold">{contest.inviteCode}</p>
          </div>
          <Button size="sm" variant="outline" onClick={() => void navigator.clipboard.writeText(contest.inviteCode ?? '')}>
            <Copy className="size-4 mr-1" /> Copy
          </Button>
          <Button size="sm" variant="ghost" onClick={() => void handleRegenCode()}>
            <RefreshCw className="size-4 mr-1" /> Regenerate
          </Button>
        </div>
      )}

      <div className="flex flex-wrap gap-3">
        <Link href={`/partner/contests/${contestId}/questions`} className={buttonVariants({ variant: 'outline' })}>
          Manage Questions
        </Link>
        <Link href={`/partner/contests/${contestId}/participants`} className={buttonVariants({ variant: 'outline' })}>
          Participants
        </Link>
        <Link href={`/partner/contests/${contestId}/leaderboard`} className={buttonVariants({ variant: 'outline' })}>
          Leaderboard
        </Link>
      </div>
    </div>
  );
}

function InfoCard({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="rounded-lg border bg-card p-4">
      <p className="text-xs text-muted-foreground">{label}</p>
      <p className="mt-1 text-2xl font-bold">{value}</p>
    </div>
  );
}
