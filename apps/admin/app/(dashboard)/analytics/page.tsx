import { apiServer } from '@/lib/api-server';
import type { DashboardStats } from '@/types/api';
import { AnalyticsCharts } from './analytics-charts';

async function getStats(): Promise<DashboardStats> {
  return apiServer.get<DashboardStats>('/v2/admin/stats/overview', {
    tags: ['stats'],
    revalidate: 300,
  });
}

export default async function AnalyticsPage() {
  let stats: DashboardStats | null = null;
  try {
    stats = await getStats();
  } catch {
    // non-fatal
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Analytics</h1>
        <p className="text-muted-foreground">Platform performance overview</p>
      </div>
      <AnalyticsCharts stats={stats} />
    </div>
  );
}
