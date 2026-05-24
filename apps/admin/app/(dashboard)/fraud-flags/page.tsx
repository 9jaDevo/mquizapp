import { apiServer } from '@/lib/api-server';
import type { FraudFlag } from '@/types/api';
import { FraudFlagsTable } from './fraud-flags-table';

interface LegacyPaginated<T> {
  items: T[];
  pagination: { page: number; limit: number; total: number; pages: number };
}

interface PageProps {
  searchParams: Promise<{ page?: string }>;
}

export default async function FraudFlagsPage({ searchParams }: PageProps) {
  const { page } = await searchParams;
  const pageIndex = Math.max(0, parseInt(page ?? '1', 10) - 1);

  let items: FraudFlag[] = [];
  let pages = 1;

  try {
    const data = await apiServer.get<LegacyPaginated<FraudFlag>>(
      `/v2/admin/fraud-flags?page=${pageIndex + 1}&limit=20`,
      { tags: ['fraud-flags'], revalidate: 30 },
    );
    items = data.items ?? [];
    pages = data.pagination?.pages ?? 1;
  } catch {
    // render empty state
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Fraud Flags</h1>
        <p className="text-muted-foreground">
          Review and resolve fraud detection events
        </p>
      </div>
      <FraudFlagsTable data={items} pageCount={pages} pageIndex={pageIndex} />
    </div>
  );
}
