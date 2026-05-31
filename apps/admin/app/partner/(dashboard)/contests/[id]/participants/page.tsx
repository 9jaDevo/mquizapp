'use client';

import { useEffect, useState } from 'react';
import { partnerApi } from '@/lib/partner-api-client';
import { Badge } from '@/components/ui/badge';

interface Participant {
  id: number; userId: number; joinedAt: string; hasSubmitted: boolean;
  submittedAt?: string; score: number; correctCount: number; timeTakenMs: number; rank: number;
}
interface Params { params: Promise<{ id: string }> }

export default function ParticipantsPage({ params }: Params) {
  const [data, setData] = useState<{ items: Participant[]; pagination: { total: number } } | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    void params.then(({ id }) => {
      void partnerApi.listParticipants(parseInt(id)).then((res) => {
        setData(res as { items: Participant[]; pagination: { total: number } });
      }).finally(() => setLoading(false));
    });
  }, [params]);

  if (loading) return <div className="text-muted-foreground">Loading…</div>;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Participants</h1>
        <p className="text-muted-foreground">{data?.pagination.total ?? 0} total</p>
      </div>
      <div className="overflow-hidden rounded-lg border">
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              <th className="px-4 py-3 text-left font-medium">User ID</th>
              <th className="px-4 py-3 text-left font-medium">Joined</th>
              <th className="px-4 py-3 text-left font-medium">Status</th>
              <th className="px-4 py-3 text-left font-medium">Score</th>
              <th className="px-4 py-3 text-left font-medium">Correct</th>
              <th className="px-4 py-3 text-left font-medium">Rank</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {data?.items.map((p) => (
              <tr key={p.id} className="hover:bg-muted/25">
                <td className="px-4 py-3">{p.userId}</td>
                <td className="px-4 py-3 text-xs text-muted-foreground">
                  {new Date(p.joinedAt).toLocaleDateString()}
                </td>
                <td className="px-4 py-3">
                  <Badge variant={p.hasSubmitted ? 'default' : 'secondary'}>
                    {p.hasSubmitted ? 'Completed' : 'Joined'}
                  </Badge>
                </td>
                <td className="px-4 py-3">{p.score.toFixed(1)}%</td>
                <td className="px-4 py-3">{p.correctCount}</td>
                <td className="px-4 py-3">{p.rank > 0 ? `#${p.rank}` : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
