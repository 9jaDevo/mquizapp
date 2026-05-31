'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { partnerApi } from '@/lib/partner-api-client';
import { Trophy, Users, BarChart3, TrendingUp } from 'lucide-react';
import Link from 'next/link';
import { buttonVariants } from '@/components/ui/button';

interface Analytics { totalContests: number; activeContests: number; totalParticipants: number }
interface Profile { orgName: string; plan: string; usage: { activeContests: number; totalContests: number; limits: { contests: number } } }

export default function PartnerDashboardPage() {
  const [profile, setProfile] = useState<Profile | null>(null);
  const [analytics, setAnalytics] = useState<Analytics | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    void Promise.all([
      partnerApi.getProfile().then(setProfile),
      partnerApi.getAnalytics().then(setAnalytics),
    ]).finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="text-muted-foreground">Loading…</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold">{profile?.orgName ?? 'Partner Dashboard'}</h1>
          <p className="text-sm text-muted-foreground capitalize">
            Plan: <span className="font-medium">{profile?.plan ?? '—'}</span>
          </p>
        </div>
        <Link href="/partner/contests/new" className={buttonVariants()}>
          + New Contest
        </Link>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard icon={Trophy} label="Total Contests" value={analytics?.totalContests ?? 0} />
        <StatCard icon={TrendingUp} label="Active Contests" value={analytics?.activeContests ?? 0} />
        <StatCard icon={Users} label="Total Participants" value={analytics?.totalParticipants ?? 0} />
        <StatCard
          icon={BarChart3}
          label="Contests Used"
          value={`${profile?.usage.activeContests ?? 0} / ${profile?.usage.limits.contests ?? '—'}`}
        />
      </div>

      <div className="rounded-lg border p-4 text-sm text-muted-foreground">
        <p>Quick links:</p>
        <div className="mt-2 flex flex-wrap gap-2">
          <Link href="/partner/contests" className="underline hover:text-foreground">View Contests</Link>
          <Link href="/partner/analytics" className="underline hover:text-foreground">Analytics</Link>
          <Link href="/partner/team" className="underline hover:text-foreground">Manage Team</Link>
          <Link href="/partner/settings" className="underline hover:text-foreground">Profile Settings</Link>
        </div>
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, label, value }: { icon: React.ElementType; label: string; value: string | number }) {
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
