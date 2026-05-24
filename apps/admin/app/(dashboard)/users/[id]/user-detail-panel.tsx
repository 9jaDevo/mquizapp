'use client';

import * as React from 'react';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type {
  BadgeStat,
  FraudFlag,
  PaginatedData,
  User,
  UserBadgesResponse,
} from '@/types/api';
import DOMPurify from 'dompurify';

interface UserDetailPanelProps {
  user: User;
}

export function UserDetailPanel({ user }: UserDetailPanelProps) {
  const api = useApiClient();
  const [isBanned, setIsBanned] = React.useState(user.isBanned);
  const [coins, setCoins] = React.useState(user.coins);
  const [showBanDialog, setShowBanDialog] = React.useState(false);
  const [showCoinDialog, setShowCoinDialog] = React.useState(false);
  const [coinAmount, setCoinAmount] = React.useState('');
  const [coinReason, setCoinReason] = React.useState('');
  const [isPending, setIsPending] = React.useState(false);

  const [fraud, setFraud] = React.useState<FraudFlag[] | null>(null);
  const [fraudLoading, setFraudLoading] = React.useState(false);
  const [badges, setBadges] = React.useState<BadgeStat[] | null>(null);
  const [badgesLoading, setBadgesLoading] = React.useState(false);

  const safeName = DOMPurify.sanitize(user.name);
  const safeEmail = user.email ? DOMPurify.sanitize(user.email) : null;

  async function handleToggleBan() {
    setIsPending(true);
    try {
      if (isBanned) {
        await api.patch(`/v2/admin/users/${user.id}/unban`, {});
        setIsBanned(false);
        toast.success('User unbanned');
      } else {
        await api.patch(`/v2/admin/users/${user.id}/ban`, {});
        setIsBanned(true);
        toast.success('User banned');
      }
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Action failed');
    } finally {
      setIsPending(false);
      setShowBanDialog(false);
    }
  }

  async function handleAdjustCoins() {
    const amount = parseInt(coinAmount, 10);
    if (!Number.isFinite(amount) || amount === 0) {
      toast.error('Enter a non-zero amount');
      return;
    }
    setIsPending(true);
    try {
      const res = await api
        .patch<{ coinsAfter: number }>(`/v2/admin/users/${user.id}/coins`, {
          amount,
          reason: coinReason || undefined,
        })
        .then((r) => r.data as { coinsAfter: number });
      setCoins(res.coinsAfter);
      toast.success(`Coins ${amount > 0 ? 'added' : 'deducted'} — new balance ${res.coinsAfter}`);
      setShowCoinDialog(false);
      setCoinAmount('');
      setCoinReason('');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Adjustment failed');
    } finally {
      setIsPending(false);
    }
  }

  async function loadFraud() {
    if (fraud !== null || fraudLoading) return;
    setFraudLoading(true);
    try {
      const res = await api
        .get<PaginatedData<FraudFlag>>(`/v2/admin/users/${user.id}/fraud-flags?limit=50`)
        .then((r) => r.data as PaginatedData<FraudFlag>);
      setFraud(res.items ?? []);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to load fraud flags');
      setFraud([]);
    } finally {
      setFraudLoading(false);
    }
  }

  async function loadBadges() {
    if (badges !== null || badgesLoading) return;
    setBadgesLoading(true);
    try {
      const res = await api
        .get<UserBadgesResponse>(`/v2/admin/users/${user.id}/badges`)
        .then((r) => r.data as UserBadgesResponse);
      setBadges(res.badges ?? []);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to load badges');
      setBadges([]);
    } finally {
      setBadgesLoading(false);
    }
  }

  return (
    <>
      <Tabs defaultValue="profile" className="w-full">
        <TabsList>
          <TabsTrigger value="profile">Profile</TabsTrigger>
          <TabsTrigger value="fraud" onClick={loadFraud}>Fraud Flags</TabsTrigger>
          <TabsTrigger value="badges" onClick={loadBadges}>Badges</TabsTrigger>
        </TabsList>

        <TabsContent value="profile">
          <div className="grid gap-6 lg:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Profile</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Name</span>
                  <span dangerouslySetInnerHTML={{ __html: safeName }} />
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Email</span>
                  <span>{safeEmail ?? '—'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Status</span>
                  {isBanned ? (
                    <Badge variant="destructive">Banned</Badge>
                  ) : (
                    <Badge variant="secondary">Active</Badge>
                  )}
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Coins</span>
                  <span>{coins.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">XP</span>
                  <span>{user.xp.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Country</span>
                  <span>{user.countryCode ?? '—'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Joined</span>
                  <span>{new Date(user.createdAt).toLocaleDateString()}</span>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Actions</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button
                  variant={isBanned ? 'default' : 'destructive'}
                  onClick={() => setShowBanDialog(true)}
                  disabled={isPending}
                  className="w-full"
                >
                  {isBanned ? 'Unban User' : 'Ban User'}
                </Button>
                <Button
                  variant="outline"
                  onClick={() => setShowCoinDialog(true)}
                  disabled={isPending}
                  className="w-full"
                >
                  Adjust Coins
                </Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="fraud">
          <Card>
            <CardHeader>
              <CardTitle>Fraud History</CardTitle>
            </CardHeader>
            <CardContent>
              {fraudLoading ? (
                <p className="text-sm text-muted-foreground py-8 text-center">
                  Loading…
                </p>
              ) : !fraud || fraud.length === 0 ? (
                <p className="text-sm text-muted-foreground py-8 text-center">
                  No fraud flags for this user.
                </p>
              ) : (
                <ul className="divide-y">
                  {fraud.map((f) => (
                    <li key={f.id} className="py-3 flex items-start gap-3 text-sm">
                      <Badge
                        variant={
                          f.severity === 'high'
                            ? 'destructive'
                            : f.severity === 'medium'
                              ? 'default'
                              : 'secondary'
                        }
                      >
                        {f.severity ?? 'low'}
                      </Badge>
                      <div className="flex-1 min-w-0">
                        <p className="font-medium">
                          {f.detectionType ?? f.detection_type ?? 'unknown'}
                        </p>
                        {f.reason && (
                          <p className="text-xs text-muted-foreground">{f.reason}</p>
                        )}
                      </div>
                      {f.resolved ? (
                        <Badge variant="secondary">Resolved</Badge>
                      ) : (
                        <Badge variant="destructive">Open</Badge>
                      )}
                    </li>
                  ))}
                </ul>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="badges">
          <Card>
            <CardHeader>
              <CardTitle>Earned Badges & Counters</CardTitle>
            </CardHeader>
            <CardContent>
              {badgesLoading ? (
                <p className="text-sm text-muted-foreground py-8 text-center">
                  Loading…
                </p>
              ) : !badges || badges.length === 0 ? (
                <p className="text-sm text-muted-foreground py-8 text-center">
                  No badges yet.
                </p>
              ) : (
                <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                  {badges.map((b) => (
                    <div
                      key={b.key}
                      className="rounded-md border p-3 flex items-center justify-between"
                    >
                      <div>
                        <p className="text-sm font-medium">{b.label}</p>
                        <p className="text-xs text-muted-foreground">
                          {b.counter} interactions
                        </p>
                      </div>
                      {b.earned && <Badge>Earned</Badge>}
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <ConfirmDialog
        open={showBanDialog}
        onOpenChange={setShowBanDialog}
        title={isBanned ? 'Unban User?' : 'Ban User?'}
        description={
          isBanned
            ? "This will restore the user's access to the platform."
            : 'This will prevent the user from accessing the platform.'
        }
        confirmWord={isBanned ? undefined : 'BAN'}
        variant={isBanned ? 'default' : 'destructive'}
        confirmLabel={isBanned ? 'Unban' : 'Ban'}
        onConfirm={handleToggleBan}
        isPending={isPending}
      />

      <Dialog open={showCoinDialog} onOpenChange={setShowCoinDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Adjust Coins</DialogTitle>
            <DialogDescription>
              Positive value adds coins; negative deducts. Current balance:{' '}
              {coins.toLocaleString()}.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <div className="space-y-2">
              <Label htmlFor="coin-amount">Amount</Label>
              <Input
                id="coin-amount"
                type="number"
                value={coinAmount}
                onChange={(e) => setCoinAmount(e.target.value)}
                placeholder="e.g. 100 or -50"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="coin-reason">Reason (optional)</Label>
              <Textarea
                id="coin-reason"
                rows={2}
                value={coinReason}
                onChange={(e) => setCoinReason(e.target.value)}
                placeholder="Why are you adjusting?"
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setShowCoinDialog(false)}
              disabled={isPending}
            >
              Cancel
            </Button>
            <Button onClick={handleAdjustCoins} disabled={isPending}>
              {isPending ? 'Applying…' : 'Apply'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
