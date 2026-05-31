'use client';

import { useEffect, useState } from 'react';
import { partnerApi } from '@/lib/partner-api-client';
import { Trophy } from 'lucide-react';

interface LeaderboardEntry {
  rank: number; userId: number; displayName: string; avatarUrl?: string;
  score: number; correctAnswers: number; timeTakenMs: number;
}
interface Params { params: Promise<{ id: string }> }

export default function LeaderboardPage({ params }: Params) {
  const [data, setData] = useState<{ entries: LeaderboardEntry[]; totalParticipants: number } | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    void params.then(({ id }) => {
      void partnerApi.getLeaderboard(parseInt(id)).then((res) => {
        setData(res as { entries: LeaderboardEntry[]; totalParticipants: number });
      }).finally(() => setLoading(false));
    });
  }, [params]);

  if (loading) return <div className="text-muted-foreground">Loading…</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <Trophy className="size-6 text-yellow-500" />
        <h1 className="text-2xl font-bold">Leaderboard</h1>
        <span className="text-muted-foreground text-sm">({data?.totalParticipants ?? 0} participants)</span>
      </div>
      <div className="overflow-hidden rounded-lg border">
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              <th className="px-4 py-3 text-left font-medium w-12">Rank</th>
              <th className="px-4 py-3 text-left font-medium">Player</th>
              <th className="px-4 py-3 text-left font-medium">Score</th>
              <th className="px-4 py-3 text-left font-medium">Correct</th>
              <th className="px-4 py-3 text-left font-medium">Time</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {data?.entries.map((e) => (
              <tr key={e.userId} className={e.rank <= 3 ? 'bg-yellow-50 dark:bg-yellow-950/20' : 'hover:bg-muted/25'}>
                <td className="px-4 py-3 font-bold text-center">
                  {e.rank === 1 ? '🥇' : e.rank === 2 ? '🥈' : e.rank === 3 ? '🥉' : `#${e.rank}`}
                </td>
                <td className="px-4 py-3 font-medium">{e.displayName}</td>
                <td className="px-4 py-3">{e.score.toFixed(1)}%</td>
                <td className="px-4 py-3">{e.correctAnswers}</td>
                <td className="px-4 py-3 text-muted-foreground">
                  {(e.timeTakenMs / 1000).toFixed(1)}s
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
