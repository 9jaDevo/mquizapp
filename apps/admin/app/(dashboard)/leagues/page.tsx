import Link from 'next/link';
import { apiServer } from '@/lib/api-server';
import { buttonVariants } from '@/components/ui/button';
import type { PaginatedData, League } from '@/types/api';
import { LeaguesTable } from './leagues-table';

interface PageProps {
  searchParams: Promise<{ page?: string }>;
}

export default async function LeaguesPage({ searchParams }: PageProps) {
  const { page } = await searchParams;
  const pageIndex = Math.max(0, parseInt(page ?? '1', 10) - 1);

  let data: PaginatedData<League> = { items: [], total: 0, page: 1, limit: 20, totalPages: 1 };

  try {
    data = await apiServer.get<PaginatedData<League>>(
      `/v2/admin/leagues?page=${pageIndex + 1}&limit=20`,
      { tags: ['leagues'], revalidate: 30 },
    );
  } catch {
    // render empty state
  }

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold">Leagues</h1>
          <p className="text-muted-foreground">Monitor active leagues and seasons</p>
        </div>
        <Link href="/leagues/new" className={buttonVariants()}>
          New League
        </Link>
      </div>
      <LeaguesTable data={data.items} pageCount={data.totalPages} pageIndex={pageIndex} />
    </div>
  );
}
