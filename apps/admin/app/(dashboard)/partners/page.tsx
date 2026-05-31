import { apiServer } from '@/lib/api-server';
import Link from 'next/link';
import { Badge } from '@/components/ui/badge';
import { buttonVariants } from '@/components/ui/button';

interface Partner {
  id: number; orgName: string; orgType: string; email: string; plan: string;
  status: string; createdAt: string; contestCount: number; teamSize: number;
}
interface PaginatedPartners { items: Partner[]; pagination: { total: number; pages: number } }

interface PageProps { searchParams: Promise<{ page?: string; status?: string; plan?: string }> }

const PLAN_COLORS: Record<string, 'default' | 'secondary' | 'outline'> = {
  free: 'secondary', starter: 'default', pro: 'default', enterprise: 'default',
};
const STATUS_COLORS: Record<string, 'default' | 'secondary' | 'outline' | 'destructive'> = {
  active: 'default', pending: 'secondary', suspended: 'destructive',
};

export default async function AdminPartnersPage({ searchParams }: PageProps) {
  const params = await searchParams;
  const page = parseInt(params.page ?? '1');

  let data: PaginatedPartners = { items: [], pagination: { total: 0, pages: 1 } };
  try {
    const sp = new URLSearchParams({ page: String(page), limit: '50' });
    if (params.status) sp.set('status', params.status);
    if (params.plan) sp.set('plan', params.plan);
    data = await apiServer.get<PaginatedPartners>(`/v2/admin/partners?${sp.toString()}`, {
      tags: ['admin-partners'], revalidate: 30,
    });
  } catch { /* render empty */ }

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold">Partners</h1>
          <p className="text-muted-foreground">{data.pagination.total} total organisations</p>
        </div>
        <div className="flex gap-2">
          {(['', 'pending', 'active', 'suspended'] as const).map((s) => (
            <Link
              key={s}
              href={`/partners${s ? `?status=${s}` : ''}`}
              className={buttonVariants({ variant: params.status === s || (!params.status && !s) ? 'default' : 'outline', size: 'sm' })}
            >
              {s || 'All'}
            </Link>
          ))}
        </div>
      </div>

      <div className="overflow-hidden rounded-lg border">
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              <th className="px-4 py-3 text-left font-medium">Organisation</th>
              <th className="px-4 py-3 text-left font-medium">Type</th>
              <th className="px-4 py-3 text-left font-medium">Plan</th>
              <th className="px-4 py-3 text-left font-medium">Status</th>
              <th className="px-4 py-3 text-left font-medium">Contests</th>
              <th className="px-4 py-3 text-left font-medium">Registered</th>
              <th className="px-4 py-3 text-left font-medium">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {data.items.map((p) => (
              <tr key={p.id} className="hover:bg-muted/25">
                <td className="px-4 py-3">
                  <div>
                    <p className="font-medium">{p.orgName}</p>
                    <p className="text-xs text-muted-foreground">{p.email}</p>
                  </div>
                </td>
                <td className="px-4 py-3 capitalize">{p.orgType}</td>
                <td className="px-4 py-3">
                  <Badge variant={PLAN_COLORS[p.plan] ?? 'secondary'} className="capitalize">
                    {p.plan}
                  </Badge>
                </td>
                <td className="px-4 py-3">
                  <Badge variant={STATUS_COLORS[p.status] ?? 'secondary'} className="capitalize">
                    {p.status}
                  </Badge>
                </td>
                <td className="px-4 py-3">{p.contestCount}</td>
                <td className="px-4 py-3 text-xs text-muted-foreground">
                  {new Date(p.createdAt).toLocaleDateString()}
                </td>
                <td className="px-4 py-3">
                  <Link href={`/partners/${p.id}`} className={buttonVariants({ variant: 'outline', size: 'sm' })}>
                    View
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
