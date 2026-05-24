import Link from 'next/link';
import { apiServer } from '@/lib/api-server';
import { buttonVariants } from '@/components/ui/button';
import type { PaginatedData, Contest } from '@/types/api';
import { ContestsTable } from './contests-table';

interface PageProps {
  searchParams: Promise<{ page?: string }>;
}

export default async function ContestsPage({ searchParams }: PageProps) {
  const { page } = await searchParams;
  const pageIndex = Math.max(0, parseInt(page ?? '1', 10) - 1);

  let data: PaginatedData<Contest> = { items: [], total: 0, page: 1, limit: 20, totalPages: 1 };

  try {
    data = await apiServer.get<PaginatedData<Contest>>(
      `/v2/admin/contests?page=${pageIndex + 1}&limit=20`,
      { tags: ['contests'], revalidate: 30 },
    );
  } catch {
    // render empty state
  }

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold">Contests</h1>
          <p className="text-muted-foreground">Manage quiz contests and prize distribution</p>
        </div>
        <Link href="/contests/new" className={buttonVariants()}>
          New Contest
        </Link>
      </div>
      <ContestsTable
        data={data.items}
        pageCount={data.totalPages}
        pageIndex={pageIndex}
      />
    </div>
  );
}
