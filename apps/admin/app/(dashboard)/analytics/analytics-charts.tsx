'use client';

import * as React from 'react';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
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
import type { DashboardStats } from '@/types/api';

interface AnalyticsChartsProps {
  stats: DashboardStats | null;
}

const COLORS = ['#6366f1', '#22c55e', '#f59e0b', '#ef4444'];

export function AnalyticsCharts({ stats }: AnalyticsChartsProps) {
  if (!stats) {
    return (
      <Card>
        <CardContent className="py-12 text-center text-muted-foreground">
          Analytics data unavailable.
        </CardContent>
      </Card>
    );
  }

  const summaryData = [
    { name: 'Users', value: stats.totalUsers },
    { name: 'Questions', value: stats.totalQuestions },
    { name: 'Active Leagues', value: stats.activeLeagues },
  ];

  const pieData = [
    { name: 'Total Users', value: stats.totalUsers },
    { name: 'Total Questions', value: stats.totalQuestions },
    { name: 'Active Leagues', value: stats.activeLeagues },
    { name: 'Fraud Reports', value: stats.unresolvedFraud },
  ];

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>Platform Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={summaryData} margin={{ top: 4, right: 16, left: 0, bottom: 4 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="value" fill="#6366f1" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Distribution</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={280}>
            <PieChart>
              <Pie
                data={pieData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={100}
                paddingAngle={3}
                dataKey="value"
              >
                {pieData.map((_, index) => (
                  <Cell key={index} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      <Card className="lg:col-span-2">
        <CardHeader>
          <CardTitle>Today&apos;s Revenue</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-3xl font-bold">
            ₦{stats.paymentsToday?.toLocaleString() ?? 0}
          </p>
          <p className="text-sm text-muted-foreground mt-1">Payments processed today</p>
        </CardContent>
      </Card>
    </div>
  );
}
