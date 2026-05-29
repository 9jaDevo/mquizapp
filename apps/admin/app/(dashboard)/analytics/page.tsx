import { apiServer } from '@/lib/api-server';
import type {
  CategoryStat,
  CountryStat,
  DashboardStats,
  RevenueSeriesPoint,
  TimeSeriesPoint,
} from '@/types/api';
import { AnalyticsCharts } from './analytics-charts';

interface SeriesResp {
  series: TimeSeriesPoint[];
}
interface RevenueResp {
  series: RevenueSeriesPoint[];
  grandTotal: number;
}
interface ItemsResp<T> {
  items: T[];
}

interface RetentionPeriod {
  cohortSize: number;
  returned: number;
  rate: number;
}

interface RetentionResp {
  d1: RetentionPeriod;
  d7: RetentionPeriod;
  d30: RetentionPeriod;
}

interface RevenueBreakdownItem {
  provider: string;
  total: number;
  count: number;
}

export default async function AnalyticsPage() {
  const [stats, growth, revenue, completions, topCats, countries, retentionResult, breakdownResult] =
    await Promise.allSettled([
      apiServer.get<DashboardStats>('/v2/admin/stats/overview', {
        tags: ['stats'],
        revalidate: 300,
      }),
      apiServer.get<SeriesResp>('/v2/admin/analytics/user-growth?days=30', {
        tags: ['analytics-user-growth'],
        revalidate: 300,
      }),
      apiServer.get<RevenueResp>('/v2/admin/analytics/revenue?days=30', {
        tags: ['analytics-revenue'],
        revalidate: 300,
      }),
      apiServer.get<SeriesResp>(
        '/v2/admin/analytics/quiz-completions?days=30',
        { tags: ['analytics-completions'], revalidate: 300 },
      ),
      apiServer.get<ItemsResp<CategoryStat>>(
        '/v2/admin/analytics/top-categories',
        { tags: ['analytics-categories'], revalidate: 600 },
      ),
      apiServer.get<ItemsResp<CountryStat>>(
        '/v2/admin/analytics/country-distribution',
        { tags: ['analytics-countries'], revalidate: 600 },
      ),
      apiServer.get<RetentionResp>('/v2/admin/analytics/retention', {
        tags: ['analytics-retention'],
        revalidate: 600,
      }),
      apiServer.get<{ items: RevenueBreakdownItem[] }>('/v2/admin/analytics/revenue-breakdown?days=30', {
        tags: ['analytics-revenue-breakdown'],
        revalidate: 300,
      }),
    ]);

  const statsVal = stats.status === 'fulfilled' ? stats.value : null;
  const growthVal =
    growth.status === 'fulfilled' ? growth.value.series : [];
  const revenueVal =
    revenue.status === 'fulfilled' ? revenue.value : { series: [], grandTotal: 0 };
  const completionsVal =
    completions.status === 'fulfilled' ? completions.value.series : [];
  const topCatsVal =
    topCats.status === 'fulfilled' ? topCats.value.items : [];
  const countriesVal =
    countries.status === 'fulfilled' ? countries.value.items : [];
  const retentionVal =
    retentionResult.status === 'fulfilled' ? retentionResult.value : null;
  const revenueBreakdownVal =
    breakdownResult.status === 'fulfilled' ? breakdownResult.value.items : [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Analytics</h1>
        <p className="text-muted-foreground">Platform performance overview</p>
      </div>
      <AnalyticsCharts
        stats={statsVal}
        userGrowth={growthVal}
        revenue={revenueVal.series}
        revenueTotal={revenueVal.grandTotal}
        completions={completionsVal}
        topCategories={topCatsVal}
        countries={countriesVal}
        retention={retentionVal}
        revenueBreakdown={revenueBreakdownVal}
      />
    </div>
  );
}
