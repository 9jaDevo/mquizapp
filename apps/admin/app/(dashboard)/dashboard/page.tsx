import { apiServer } from '@/lib/api-server';
import type { DashboardStats } from '@/types/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Users, HelpCircle, Shield, AlertTriangle, CreditCard } from 'lucide-react';

async function getStats(): Promise<DashboardStats> {
  return apiServer.get<DashboardStats>('/v2/admin/stats/overview', {
    tags: ['dashboard-stats'],
    revalidate: 60,
  });
}

export default async function DashboardPage() {
  let stats: DashboardStats | null = null;
  let error: string | null = null;

  try {
    stats = await getStats();
  } catch (e) {
    error = e instanceof Error ? e.message : 'Failed to load stats';
  }

  const statCards = [
    { label: 'Total Users', value: stats?.totalUsers, icon: Users },
    { label: 'Total Questions', value: stats?.totalQuestions, icon: HelpCircle },
    { label: 'Active Leagues', value: stats?.activeLeagues, icon: Shield },
    { label: 'Unresolved Fraud', value: stats?.unresolvedFraud, icon: AlertTriangle },
    { label: 'Payments Today', value: stats?.successfulPaymentsToday, icon: CreditCard },
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
        {statCards.map(({ label, value, icon: Icon }) => (
          <Card key={label}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{label}</CardTitle>
              <Icon className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {value !== undefined ? value.toLocaleString() : '—'}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
