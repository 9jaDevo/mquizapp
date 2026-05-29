'use client';

import {
  ResponsiveContainer,
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  Tooltip,
} from 'recharts';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import type { CategoryStat, TimeSeriesPoint } from '@/types/api';

interface DashboardMiniChartsProps {
  userGrowth: TimeSeriesPoint[];
  completions: TimeSeriesPoint[];
  topCategories: CategoryStat[];
}

const fmt = (d: string) =>
  new Date(d).toLocaleDateString('en', { month: 'short', day: 'numeric' });

export function DashboardMiniCharts({
  userGrowth,
  completions,
  topCategories,
}: DashboardMiniChartsProps) {
  return (
    <div className="grid gap-4 md:grid-cols-3">
      <Card>
        <CardHeader className="pb-1">
          <CardTitle className="text-sm font-medium">New Users (7d)</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={80}>
            <AreaChart data={userGrowth}>
              <defs>
                <linearGradient id="ugGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#6366f1" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
                </linearGradient>
              </defs>
              <XAxis
                dataKey="date"
                tickFormatter={fmt}
                tick={{ fontSize: 10 }}
                tickLine={false}
                axisLine={false}
                interval="preserveStartEnd"
              />
              <Tooltip
                formatter={(v) => [(v as number).toLocaleString(), 'Users']}
                labelFormatter={(d) => fmt(d as string)}
              />
              <Area
                type="monotone"
                dataKey="count"
                stroke="#6366f1"
                fill="url(#ugGrad)"
                strokeWidth={2}
                dot={false}
              />
            </AreaChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="pb-1">
          <CardTitle className="text-sm font-medium">Quiz Completions (7d)</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={80}>
            <BarChart data={completions} barSize={8}>
              <XAxis
                dataKey="date"
                tickFormatter={fmt}
                tick={{ fontSize: 10 }}
                tickLine={false}
                axisLine={false}
                interval="preserveStartEnd"
              />
              <Tooltip
                formatter={(v) => [(v as number).toLocaleString(), 'Sessions']}
                labelFormatter={(d) => fmt(d as string)}
              />
              <Bar dataKey="count" fill="#22c55e" radius={[2, 2, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="pb-1">
          <CardTitle className="text-sm font-medium">Top Categories</CardTitle>
        </CardHeader>
        <CardContent>
          <ul className="space-y-2">
            {topCategories.slice(0, 5).map((c) => (
              <li key={c.categoryId} className="flex items-center justify-between text-xs">
                <span className="max-w-[140px] truncate text-muted-foreground">{c.name}</span>
                <span className="font-medium tabular-nums">
                  {c.questionCount.toLocaleString()}
                </span>
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </div>
  );
}
