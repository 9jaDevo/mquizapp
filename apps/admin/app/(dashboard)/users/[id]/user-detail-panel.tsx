'use client';

import * as React from 'react';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { User } from '@/types/api';
import DOMPurify from 'dompurify';

interface UserDetailPanelProps {
  user: User;
}

export function UserDetailPanel({ user }: UserDetailPanelProps) {
  const api = useApiClient();
  const [isBanned, setIsBanned] = React.useState(user.isBanned);
  const [showBanDialog, setShowBanDialog] = React.useState(false);
  const [isPending, setIsPending] = React.useState(false);

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

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>Profile</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3 text-sm">
          <div className="flex justify-between">
            <span className="text-muted-foreground">Name</span>
            {/* Safe: sanitized with DOMPurify */}
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
            <span>{user.coins.toLocaleString()}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">XP</span>
            <span>{user.xp.toLocaleString()}</span>
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
          >
            {isBanned ? 'Unban User' : 'Ban User'}
          </Button>
        </CardContent>
      </Card>

      <ConfirmDialog
        open={showBanDialog}
        onOpenChange={setShowBanDialog}
        title={isBanned ? 'Unban User?' : 'Ban User?'}
        description={
          isBanned
            ? 'This will restore the user\'s access to the platform.'
            : 'This will prevent the user from accessing the platform.'
        }
        confirmWord={isBanned ? undefined : 'BAN'}
        variant={isBanned ? 'default' : 'destructive'}
        confirmLabel={isBanned ? 'Unban' : 'Ban'}
        onConfirm={handleToggleBan}
        isPending={isPending}
      />
    </div>
  );
}
