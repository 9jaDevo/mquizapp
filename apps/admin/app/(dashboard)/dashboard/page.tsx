import { apiServer } from '@/lib/api-server';
import type { CategoryStat, DashboardStats, TimeSeriesPoint } from '@/types/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import Link from 'next/link';
import {
  Users,
  HelpCircle,
  Shield,
  AlertTriangle,
  CreditCard,
  Trophy,
  Activity,
  Calendar,
  Sparkles,
} from 'lucide-react';
import { DashboardMiniCharts } from './dashboard-mini-charts';

export default async function DashboardPage() {
  const [statsResult, growthResult, completionsResult, topCatsResult] = await Promise.allSettled([
    apiServer.get<DashboardStats>('/v2/admin/stats/overview', {
      tags: ['dashboard-stats'],
      revalidate: 60,
    }),
    apiServer.get<{ series: TimeSeriesPoint[] }>('/v2/admin/analytics/user-growth?days=7', {
      tags: ['dashboard-user-growth'],
      revalidate: 300,
    }),
    apiServer.get<{ series: TimeSeriesPoint[] }>('/v2/admin/analytics/quiz-completions?days=7', {
      tags: ['dashboard-completions'],
      revalidate: 300,
    }),
    apiServer.get<{ items: CategoryStat[] }>('/v2/admin/analytics/top-categories', {
      tags: ['dashboard-top-cats'],
      revalidate: 600,
    }),
  ]);

  const stats = statsResult.status === 'fulfilled' ? statsResult.value : null;
  const error = statsResult.status === 'rejected'
    ? (statsResult.reason instanceof Error ? statsResult.reason.message : 'Failed to load stats')
    : null;
  const userGrowth = growthResult.status === 'fulfilled' ? growthResult.value.series : [];
  const completions = completionsResult.status === 'fulfilled' ? completionsResult.value.series : [];
  const topCategories = topCatsResult.status === 'fulfilled' ? topCatsResult.value.items : [];

  const statCards = [
    { label: 'Total Users', value: stats?.totalUsers, icon: Users, color: 'text-blue-500' },
    { label: 'DAU (24h)', value: stats?.dau, icon: Activity, color: 'text-green-500' },
    { label: 'MAU (30d)', value: stats?.mau, icon: Calendar, color: 'text-emerald-500' },
    { label: 'Total Questions', value: stats?.totalQuestions, icon: HelpCircle, color: 'text-indigo-500' },
    { label: 'Pending AI Questions', value: stats?.pendingAiQuestions, icon: Sparkles, color: 'text-purple-500' },
    { label: 'Active Leagues', value: stats?.activeLeagues, icon: Shield, color: 'text-cyan-500' },
    { label: 'Active Contests', value: stats?.activeContests, icon: Trophy, color: 'text-amber-500' },
    { label: 'Unresolved Fraud', value: stats?.unresolvedFraud, icon: AlertTriangle, color: 'text-red-500' },
    { label: 'Payments Today', value: stats?.successfulPaymentsToday, icon: CreditCard, color: 'text-pink-500' },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">Platform overview</p>
      </div>

      {error && (
        <div className="rounded-md bg-destructive/10 px-4 py-3 text-sm text-destructive">
          {error}
        </div>
      )}

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5">
        {statCards.map(({ label, value, icon: Icon, color }) => (
          <Card key={label}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{label}</CardTitle>
              <Icon className={`h-4 w-4 ${color}`} />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {value !== undefined && value !== null ? value.toLocaleString() : '—'}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {stats?.recentFraud && stats.recentFraud.length > 0 && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="text-base">Recent Fraud Alerts</CardTitle>
            <Link
              href="/fraud-flags"
              className="text-xs text-muted-foreground hover:text-foreground"
            >
              View all →
            </Link>
          </CardHeader>
          <CardContent>
            <ul className="divide-y">
              {stats.recentFraud.map((f) => (
                <li key={f.id} className="flex items-start gap-3 py-2 text-sm">
                  <Badge
                    variant={
                      f.severity === 'high'
                        ? 'destructive'
                        : f.severity === 'medium'
                          ? 'default'
                          : 'secondary'
                    }
                  >
                    {f.severity || 'low'}
                  </Badge>
                  <div className="flex-1 min-w-0">
                    <p className="font-medium">
                      {f.detectionType}{' '}
                      <span className="text-muted-foreground font-normal">
                        · user #{f.userId ?? '—'}
                      </span>
                    </p>
                    {f.reason && (
                      <p className="text-xs text-muted-foreground truncate">{f.reason}</p>
                    )}
                  </div>
                  <span className="text-xs text-muted-foreground whitespace-nowrap">
                    {f.createdAt ? new Date(f.createdAt).toLocaleString() : ''}
                  </span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      )}

      <DashboardMiniCharts
        userGrowth={userGrowth}
        completions={completions}
        topCategories={topCategories}
      />
    </div>
  );
}
