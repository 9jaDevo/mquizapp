'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useApiClient } from '@/hooks/use-api-client';
import type { League } from '@/types/api';

const schema = z.object({
  name: z.string().min(2, 'Name is required').max(255),
  description: z.string().optional(),
  startDate: z.string().min(1, 'Start date is required'),
  endDate: z.string().min(1, 'End date is required'),
  entry: z.string().optional(),
  image: z.string().optional(),
  status: z.enum(['0', '1']),
});

type FormData = z.infer<typeof schema>;

function toLocalInput(iso?: string | null): string {
  if (!iso) return '';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  const pad = (n: number) => n.toString().padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export function LeagueForm({ league }: { league?: League | null }) {
  const router = useRouter();
  const api = useApiClient();
  const isEdit = Boolean(league);

  const {
    register,
    handleSubmit,
    setValue,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      name: league?.name ?? '',
      description: league?.description ?? '',
      startDate: toLocalInput(league?.startDate),
      endDate: toLocalInput(league?.endDate),
      entry: league?.entry?.toString() ?? '0',
      image: league?.image ?? '',
      status:
        league?.statusCode === 0
          ? '0'
          : league?.status === 'active' || league?.statusCode === 1
            ? '1'
            : '1',
    },
  });

  async function onSubmit(data: FormData) {
    try {
      const payload = {
        name: data.name,
        description: data.description || undefined,
        startDate: new Date(data.startDate).toISOString(),
        endDate: new Date(data.endDate).toISOString(),
        entry: Math.max(0, Math.floor(Number(data.entry) || 0)),
        image: data.image || undefined,
        status: parseInt(data.status, 10),
      };
      if (isEdit && league) {
        await api.put(`/v2/admin/leagues/${league.id}`, payload);
        toast.success('League updated');
      } else {
        await api.post('/v2/admin/leagues', payload);
        toast.success('League created');
      }
      router.push('/leagues');
      router.refresh();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Save failed');
    }
  }

  return (
    <Card>
      <CardContent className="pt-6">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="name">Name</Label>
            <Input id="name" {...register('name')} />
            {errors.name && (
              <p className="text-sm text-destructive">{errors.name.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Description (optional)</Label>
            <Textarea id="description" rows={3} {...register('description')} />
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="startDate">Start Date</Label>
              <Input id="startDate" type="datetime-local" {...register('startDate')} />
              {errors.startDate && (
                <p className="text-sm text-destructive">{errors.startDate.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="endDate">End Date</Label>
              <Input id="endDate" type="datetime-local" {...register('endDate')} />
              {errors.endDate && (
                <p className="text-sm text-destructive">{errors.endDate.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="entry">Entry Fee (coins)</Label>
              <Input id="entry" type="number" min={0} {...register('entry')} />
            </div>
            <div className="space-y-2">
              <Label>Status</Label>
              <Select
                onValueChange={(v) => v && setValue('status', v as '0' | '1')}
                defaultValue={league?.statusCode === 0 ? '0' : '1'}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="1">Active</SelectItem>
                  <SelectItem value="0">Inactive</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="image">Image URL (optional)</Label>
            <Input id="image" {...register('image')} placeholder="https://..." />
          </div>

          <div className="flex gap-3">
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Saving…' : isEdit ? 'Update League' : 'Create League'}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => router.back()}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
