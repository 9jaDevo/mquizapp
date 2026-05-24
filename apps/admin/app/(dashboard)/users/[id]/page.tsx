import { apiServer } from '@/lib/api-server';
import type { User } from '@/types/api';
import { UserDetailPanel } from './user-detail-panel';
import { notFound } from 'next/navigation';

async function getUser(id: string): Promise<User> {
  return apiServer.get<User>(`/v2/admin/users/${id}`, {
    tags: [`user-${id}`],
    revalidate: 60,
  });
}

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  let user: User | null = null;

  try {
    user = await getUser(id);
  } catch {
    notFound();
  }

  if (!user) notFound();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">User Detail</h1>
        <p className="text-muted-foreground">ID: {id}</p>
      </div>
      <UserDetailPanel user={user} />
    </div>
  );
}
