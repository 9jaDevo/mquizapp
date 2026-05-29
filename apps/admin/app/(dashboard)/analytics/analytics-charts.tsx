'use client';

import * as React from 'react';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import type {
  CategoryStat,
  CountryStat,
  DashboardStats,
  RevenueSeriesPoint,
  TimeSeriesPoint,
} from '@/types/api';

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

interface AnalyticsChartsProps {
  stats: DashboardStats | null;
  userGrowth: TimeSeriesPoint[];
  revenue: RevenueSeriesPoint[];
  revenueTotal: number;
  completions: TimeSeriesPoint[];
  topCategories: CategoryStat[];
  countries: CountryStat[];
  retention?: RetentionResp | null;
  revenueBreakdown?: RevenueBreakdownItem[] | null;
}

const COLORS = [
  '#6366f1',
  '#22c55e',
  '#f59e0b',
  '#ef4444',
  '#06b6d4',
  '#a855f7',
  '#ec4899',
  '#84cc16',
  '#0ea5e9',
  '#f97316',
];

function fmtDate(d: string) {
  return d.slice(5);
}

export function AnalyticsCharts({
  stats,
  userGrowth,
  revenue,
  revenueTotal,
  completions,
  topCategories,
  countries,
  retention,
  revenueBreakdown,
}: AnalyticsChartsProps) {
  return (
    <div className="space-y-6">
      {/* KPI strip */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">
              Revenue (30d)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">₦{revenueTotal.toLocaleString()}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">
              New Users (30d)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">
              {userGrowth.reduce((s, p) => s + p.count, 0).toLocaleString()}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">
              Quizzes (30d)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">
              {completions.reduce((s, p) => s + p.count, 0).toLocaleString()}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">DAU / MAU</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">
              {stats?.dau?.toLocaleString() ?? '—'} /{' '}
              {stats?.mau?.toLocaleString() ?? '—'}
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>User Growth (last 30 days)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <LineChart
                data={userGrowth.map((p) => ({ ...p, label: fmtDate(p.date) }))}
                margin={{ top: 4, right: 16, left: 0, bottom: 4 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="label" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="count"
                  stroke="#6366f1"
                  strokeWidth={2}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Revenue (last 30 days)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart
                data={revenue.map((p) => ({ ...p, label: fmtDate(p.date) }))}
                margin={{ top: 4, right: 16, left: 0, bottom: 4 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="label" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip
                  formatter={(v) => `₦${Number(v).toLocaleString()}`}
                />
                <Bar dataKey="total" fill="#22c55e" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Quiz Completions (last 30 days)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <LineChart
                data={completions.map((p) => ({ ...p, label: fmtDate(p.date) }))}
                margin={{ top: 4, right: 16, left: 0, bottom: 4 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="label" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="count"
                  stroke="#f59e0b"
                  strokeWidth={2}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Top Categories</CardTitle>
          </CardHeader>
          <CardContent>
            {topCategories.length === 0 ? (
              <p className="py-12 text-center text-sm text-muted-foreground">
                No data
              </p>
            ) : (
              <ResponsiveContainer width="100%" height={280}>
                <PieChart>
                  <Pie
                    data={topCategories}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={100}
                    paddingAngle={3}
                    dataKey="questionCount"
                    nameKey="name"
                  >
                    {topCategories.map((_, i) => (
                      <Cell key={i} fill={COLORS[i % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend wrapperStyle={{ fontSize: 11 }} />
                </PieChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Country Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            {countries.length === 0 ? (
              <p className="py-12 text-center text-sm text-muted-foreground">
                No data
              </p>
            ) : (
              <ResponsiveContainer width="100%" height={280}>
                <BarChart
                  data={countries}
                  layout="vertical"
                  margin={{ top: 4, right: 16, left: 24, bottom: 4 }}
                >
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" tick={{ fontSize: 11 }} />
                  <YAxis
                    type="category"
                    dataKey="country"
                    tick={{ fontSize: 11 }}
                    width={56}
                  />
                  <Tooltip />
                  <Bar dataKey="count" fill="#06b6d4" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>
      </div>

      {revenueBreakdown && revenueBreakdown.length > 0 && (
        <div>
          <h2 className="mb-4 text-lg font-semibold">Revenue by Provider (30d)</h2>
          <Card>
            <CardContent className="pt-4">
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={revenueBreakdown} margin={{ top: 4, right: 16, left: 0, bottom: 4 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="provider" tick={{ fontSize: 12 }} />
                  <YAxis tick={{ fontSize: 12 }} tickFormatter={(v: number) => `₦${(v / 1000).toFixed(0)}k`} />
                  <Tooltip formatter={(v) => [`₦${(v as number).toLocaleString()}`, 'Revenue']} />
                  <Bar dataKey="total" fill="#6366f1" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>
      )}

      {retention && (
        <div>
          <h2 className="mb-4 text-lg font-semibold">User Retention</h2>
          <div className="grid gap-4 sm:grid-cols-3">
            {(
              [
                { label: 'Day 1 Retention', period: retention.d1 },
                { label: 'Day 7 Retention', period: retention.d7 },
                { label: 'Day 30 Retention', period: retention.d30 },
              ] as const
            ).map(({ label, period }) => (
              <Card key={label}>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm text-muted-foreground">{label}</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-2xl font-bold">{(period.rate * 100).toFixed(1)}%</p>
                  <p className="text-xs text-muted-foreground">
                    {period.returned.toLocaleString()} / {period.cohortSize.toLocaleString()} users
                  </p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
