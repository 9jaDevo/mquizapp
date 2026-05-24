import { notFound } from 'next/navigation';
import { apiServer } from '@/lib/api-server';
import type { Contest } from '@/types/api';
import { ContestForm } from '../../contest-form';

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function EditContestPage({ params }: PageProps) {
  const { id } = await params;
  let contest: Contest | null = null;
  try {
    contest = await apiServer.get<Contest>(`/v2/admin/contests/${id}`);
  } catch {
    notFound();
  }
  if (!contest) notFound();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Edit Contest</h1>
        <p className="text-muted-foreground">#{contest.id} — {contest.name ?? contest.title}</p>
      </div>
      <ContestForm contest={contest} />
    </div>
  );
}
