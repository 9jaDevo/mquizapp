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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useApiClient } from '@/hooks/use-api-client';

const schema = z.object({
  title: z.string().min(1, 'Title is required').max(100),
  body: z.string().min(1, 'Message body is required').max(500),
  targetAudience: z.enum(['all', 'active', 'inactive']),
  deepLink: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

export function NotificationsPanel() {
  const api = useApiClient();

  const {
    register,
    handleSubmit,
    setValue,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { targetAudience: 'all' },
  });

  async function onSend(data: FormData) {
    try {
      const result = await api
        .post<{ sent: number }>('/v2/admin/notifications/broadcast', data)
        .then((r) => r.data as { sent: number });
      toast.success(`Notification sent to ${result?.sent ?? 'all'} users`);
      reset();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to send notification');
    }
  }

  return (
    <Card className="max-w-2xl">
      <CardHeader>
        <CardTitle>Broadcast Notification</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSend)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="title">Title</Label>
            <Input id="title" {...register('title')} placeholder="Notification title" />
            {errors.title && (
              <p className="text-sm text-destructive">{errors.title.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="body">Message</Label>
            <Textarea
              id="body"
              {...register('body')}
              rows={3}
              placeholder="Notification body text"
            />
            {errors.body && (
              <p className="text-sm text-destructive">{errors.body.message}</p>
            )}
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label>Target Audience</Label>
              <Select
                onValueChange={(v) => setValue('targetAudience', v as FormData['targetAudience'])}
                defaultValue="all"
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Users</SelectItem>
                  <SelectItem value="active">Active (last 7 days)</SelectItem>
                  <SelectItem value="inactive">Inactive (30+ days)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="deepLink">Deep Link (optional)</Label>
              <Input
                id="deepLink"
                {...register('deepLink')}
                placeholder="e.g. mquiz://contest/123"
              />
            </div>
          </div>

          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? 'Sending...' : 'Send Notification'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
