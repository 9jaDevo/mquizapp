import { notFound } from 'next/navigation';
import { apiServer } from '@/lib/api-server';
import type { League } from '@/types/api';
import { LeagueForm } from '../../league-form';

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function EditLeaguePage({ params }: PageProps) {
  const { id } = await params;
  let league: League | null = null;
  try {
    league = await apiServer.get<League>(`/v2/admin/leagues/${id}`);
  } catch {
    notFound();
  }
  if (!league) notFound();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Edit League</h1>
        <p className="text-muted-foreground">#{league.id} — {league.name}</p>
      </div>
      <LeagueForm league={league} />
    </div>
  );
}
