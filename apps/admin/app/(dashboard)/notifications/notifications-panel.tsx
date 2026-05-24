'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { useApiClient } from '@/hooks/use-api-client';
import type { NotificationHistoryItem } from '@/types/api';

const schema = z.object({
  title: z.string().min(2, 'Title is required').max(128),
  message: z.string().min(2, 'Message is required').max(2048),
  type: z.string().max(64).optional(),
  image: z.string().max(256).optional(),
  userIds: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

interface HistoryResp {
  items: NotificationHistoryItem[];
  pagination?: { page: number; limit: number; total: number; pages: number };
}

export function NotificationsPanel() {
  const api = useApiClient();
  const [history, setHistory] = React.useState<NotificationHistoryItem[]>([]);
  const [loadingHistory, setLoadingHistory] = React.useState(true);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  const loadHistory = React.useCallback(async () => {
    setLoadingHistory(true);
    try {
      const res = await api
        .get<HistoryResp>('/v2/admin/notifications?page=1&limit=20')
        .then((r) => r.data as HistoryResp);
      setHistory(res.items ?? []);
    } catch {
      setHistory([]);
    } finally {
      setLoadingHistory(false);
    }
  }, [api]);

  React.useEffect(() => {
    loadHistory();
  }, [loadHistory]);

  async function onSubmit(data: FormData) {
    try {
      const userIds = data.userIds
        ? data.userIds
            .split(',')
            .map((s) => parseInt(s.trim(), 10))
            .filter((n) => Number.isFinite(n) && n > 0)
        : undefined;

      const payload = {
        title: data.title,
        message: data.message,
        type: data.type || undefined,
        image: data.image || undefined,
        userIds: userIds && userIds.length ? userIds : undefined,
      };

      await api.post('/v2/admin/notifications/send', payload);
      toast.success(
        userIds && userIds.length
          ? `Sent to ${userIds.length} user(s)`
          : 'Broadcast queued for delivery',
      );
      reset();
      loadHistory();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Send failed');
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-3">
      <Card className="lg:col-span-2">
        <CardHeader>
          <CardTitle>Send Notification</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="title">Title</Label>
              <Input id="title" {...register('title')} placeholder="Notification title" />
              {errors.title && (
                <p className="text-sm text-destructive">{errors.title.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="message">Message</Label>
              <Textarea
                id="message"
                rows={3}
                {...register('message')}
                placeholder="What's the message?"
              />
              {errors.message && (
                <p className="text-sm text-destructive">{errors.message.message}</p>
              )}
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="type">Type (optional)</Label>
                <Input
                  id="type"
                  {...register('type')}
                  placeholder="e.g. announcement, contest"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="image">Image URL (optional)</Label>
                <Input id="image" {...register('image')} placeholder="https://..." />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="userIds">Target User IDs (optional, comma-separated)</Label>
              <Input
                id="userIds"
                {...register('userIds')}
                placeholder="Leave empty to broadcast to all users"
              />
              <p className="text-xs text-muted-foreground">
                Leave empty to broadcast to all users. Max 1000 IDs.
              </p>
            </div>

            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Sending…' : 'Send Notification'}
            </Button>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Recent History</CardTitle>
        </CardHeader>
        <CardContent>
          {loadingHistory ? (
            <p className="text-sm text-muted-foreground py-6 text-center">Loading…</p>
          ) : history.length === 0 ? (
            <p className="text-sm text-muted-foreground py-6 text-center">
              No notifications sent yet.
            </p>
          ) : (
            <ul className="divide-y max-h-[500px] overflow-y-auto">
              {history.map((n) => (
                <li key={n.id} className="py-3 space-y-1">
                  <div className="flex items-center justify-between gap-2">
                    <p className="text-sm font-medium truncate">{n.title}</p>
                    {n.audience && (
                      <Badge variant="secondary" className="text-xs">
                        {n.audience}
                      </Badge>
                    )}
                  </div>
                  <p className="text-xs text-muted-foreground line-clamp-2">
                    {n.message}
                  </p>
                  {n.dateSent && (
                    <p className="text-xs text-muted-foreground">
                      {new Date(n.dateSent).toLocaleString()}
                    </p>
                  )}
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
