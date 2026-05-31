'use client';

import { useEffect, useState } from 'react';
import { partnerApi } from '@/lib/partner-api-client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { BarChart3, Trophy, TrendingUp, Users } from 'lucide-react';

interface Analytics { totalContests: number; activeContests: number; totalParticipants: number }

export default function PartnerAnalyticsPage() {
  const [data, setData] = useState<Analytics | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    void partnerApi.getAnalytics().then((res) => setData(res as Analytics)).finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="text-muted-foreground">Loading…</div>;

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Analytics</h1>
      <div className="grid gap-4 sm:grid-cols-3">
        <Stat icon={Trophy} label="Total Contests" value={data?.totalContests ?? 0} />
        <Stat icon={TrendingUp} label="Active Contests" value={data?.activeContests ?? 0} />
        <Stat icon={Users} label="Total Participants" value={data?.totalParticipants ?? 0} />
      </div>
      <p className="text-sm text-muted-foreground">
        For per-contest analytics, open a contest and view its detail page.
      </p>
    </div>
  );
}

function Stat({ icon: Icon, label, value }: { icon: React.ElementType; label: string; value: number }) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">{label}</CardTitle>
        <Icon className="size-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <p className="text-2xl font-bold">{value}</p>
      </CardContent>
    </Card>
  );
}
