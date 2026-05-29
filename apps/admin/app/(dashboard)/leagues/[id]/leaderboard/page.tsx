import Link from 'next/link';
import { notFound } from 'next/navigation';
import { apiServer } from '@/lib/api-server';
import type { LeagueLeaderboardEntry } from '@/types/api';

interface LeaderboardResp {
  leagueId: number;
  leagueName: string;
  entries: LeagueLeaderboardEntry[];
}

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function LeagueLeaderboardPage({ params }: PageProps) {
  const { id } = await params;
  let data: LeaderboardResp | null = null;
  try {
    data = await apiServer.get<LeaderboardResp>(
      `/v2/admin/leagues/${id}/leaderboard?limit=50`,
    );
  } catch {
    notFound();
  }
  if (!data) notFound();

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2 text-sm text-muted-foreground">
        <Link href="/leagues" className="hover:text-foreground transition-colors">
          ← Back to Leagues
        </Link>
      </div>

      <div>
        <h1 className="text-2xl font-bold">League Leaderboard</h1>
        <p className="text-muted-foreground">{data.leagueName}</p>
      </div>

      {data.entries.length === 0 ? (
        <p className="rounded-lg border py-12 text-center text-sm text-muted-foreground">
          No participants yet.
        </p>
      ) : (
        <div className="rounded-lg border">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-muted/50">
                <th className="w-16 px-4 py-3 text-left font-medium">Rank</th>
                <th className="px-4 py-3 text-left font-medium">Player</th>
                <th className="px-4 py-3 text-right font-medium">Score</th>
                <th className="px-4 py-3 text-right font-medium">Games</th>
              </tr>
            </thead>
            <tbody>
              {data.entries.map((entry) => (
                <tr key={entry.userId} className="border-b last:border-0 hover:bg-muted/30 transition-colors">
                  <td className="px-4 py-3 font-medium text-muted-foreground">
                    {entry.rank === 1
                      ? '🥇'
                      : entry.rank === 2
                        ? '🥈'
                        : entry.rank === 3
                          ? '🥉'
                          : `#${entry.rank}`}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      {entry.profile ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={entry.profile}
                          alt={entry.name}
                          className="h-8 w-8 rounded-full object-cover"
                        />
                      ) : (
                        <div className="flex h-8 w-8 items-center justify-center rounded-full bg-muted text-xs font-medium">
                          {entry.name.charAt(0).toUpperCase()}
                        </div>
                      )}
                      <span className="font-medium">{entry.name}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-right font-mono">
                    {entry.score.toLocaleString()}
                  </td>
                  <td className="px-4 py-3 text-right text-muted-foreground">
                    {entry.gamesPlayed}
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
