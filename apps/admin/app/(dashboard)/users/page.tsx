import { apiServer } from '@/lib/api-server';
import type { PaginatedData, User } from '@/types/api';
import { UsersTable } from './users-table';

interface UsersQuery {
  page?: string;
  status?: string;
  firebaseId?: string;
}

async function getUsers(
  page = 1,
  limit = 20,
  status?: string,
  firebaseId?: string,
): Promise<PaginatedData<User>> {
  const sp = new URLSearchParams();
  sp.set('page', String(page));
  sp.set('limit', String(limit));
  if (status !== undefined && status !== '') sp.set('status', status);
  if (firebaseId) sp.set('firebaseId', firebaseId);
  return apiServer.get<PaginatedData<User>>(
    `/v2/admin/users?${sp.toString()}`,
    { tags: ['users'], revalidate: 60 },
  );
}

export default async function UsersPage({
  searchParams,
}: {
  searchParams: Promise<UsersQuery>;
}) {
  const params = await searchParams;
  const page = parseInt(params.page ?? '1', 10);

  let data: PaginatedData<User> | null = null;
  let error: string | null = null;

  try {
    data = await getUsers(page, 20, params.status, params.firebaseId);
  } catch (e) {
    error = e instanceof Error ? e.message : 'Failed to load users';
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Users</h1>
        <p className="text-muted-foreground">Manage registered users</p>
      </div>

      {error && (
        <div className="rounded-md bg-destructive/10 px-4 py-3 text-sm text-destructive">
          {error}
        </div>
      )}

      <UsersTable
        users={data?.items ?? []}
        pageCount={data?.totalPages ?? 1}
        pageIndex={page - 1}
        initialStatus={params.status ?? ''}
        initialFirebaseId={params.firebaseId ?? ''}
      />
    </div>
  );
}
