'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import DOMPurify from 'dompurify';
import { Pencil, Trash2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { Sponsor } from '@/types/api';

const schema = z.object({
  sponsorName: z.string().min(1, 'Sponsor name is required').max(255),
  title: z.string().max(255).optional().or(z.literal('')),
  imageUrl: z.string().url('Must be a valid URL'),
  redirectUrl: z.string().url('Must be a valid URL').optional().or(z.literal('')),
  startDate: z.string().min(1, 'Start date is required'),
  endDate: z.string().min(1, 'End date is required'),
  priority: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

interface SponsorsManagerProps {
  initialSponsors: Sponsor[];
}

export function SponsorsManager({ initialSponsors }: SponsorsManagerProps) {
  const api = useApiClient();
  const [sponsors, setSponsors] = React.useState<Sponsor[]>(initialSponsors);
  const [deleteTarget, setDeleteTarget] = React.useState<Sponsor | null>(null);
  const [editTarget, setEditTarget] = React.useState<Sponsor | null>(null);
  const [editForm, setEditForm] = React.useState({
    sponsorName: '',
    title: '',
    imageUrl: '',
    redirectUrl: '',
    priority: '0',
    isActive: 1 as 0 | 1,
  });
  const [isSavingEdit, setIsSavingEdit] = React.useState(false);

  function openEdit(sponsor: Sponsor) {
    setEditTarget(sponsor);
    setEditForm({
      sponsorName: sponsor.sponsorName ?? sponsor.name ?? '',
      title: sponsor.title ?? '',
      imageUrl: sponsor.imageUrl ?? sponsor.logoUrl ?? '',
      redirectUrl: sponsor.redirectUrl ?? sponsor.websiteUrl ?? '',
      priority: (sponsor.priority ?? 0).toString(),
      isActive: sponsor.isActive ? 1 : 0,
    });
  }

  async function handleEditSave() {
    if (!editTarget) return;
    setIsSavingEdit(true);
    try {
      const payload = {
        sponsorName: editForm.sponsorName,
        title: editForm.title || undefined,
        imageUrl: editForm.imageUrl,
        redirectUrl: editForm.redirectUrl || undefined,
        priority: Math.max(0, Math.floor(Number(editForm.priority) || 0)),
        isActive: editForm.isActive,
      };
      const updated = await api
        .patch<Sponsor>(`/v2/admin/sponsors/${editTarget.id}`, payload)
        .then((r) => r.data as Sponsor);
      setSponsors((prev) => prev.map((s) => (s.id === editTarget.id ? { ...s, ...updated } : s)));
      toast.success('Sponsor updated');
      setEditTarget(null);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Update failed');
    } finally {
      setIsSavingEdit(false);
    }
  }

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  async function onCreate(data: FormData) {
    try {
      const payload = {
        sponsorName: data.sponsorName,
        title: data.title || undefined,
        imageUrl: data.imageUrl,
        redirectUrl: data.redirectUrl || undefined,
        startDate: new Date(data.startDate).toISOString(),
        endDate: new Date(data.endDate).toISOString(),
        priority: data.priority ? Math.max(0, Math.floor(Number(data.priority) || 0)) : 0,
        isActive: 1,
      };
      const created = await api
        .post<Sponsor>('/v2/admin/sponsors', payload)
        .then((r) => r.data as Sponsor);
      setSponsors((prev) => [created, ...prev]);
      reset();
      toast.success('Sponsor created');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to create sponsor');
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    try {
      await api.delete(`/v2/admin/sponsors/${deleteTarget.id}`);
      setSponsors((prev) => prev.filter((s) => s.id !== deleteTarget.id));
      toast.success('Sponsor deleted');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete sponsor');
    } finally {
      setDeleteTarget(null);
    }
  }

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Add Sponsor</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onCreate)} className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="sponsorName">Sponsor Name</Label>
                <Input id="sponsorName" {...register('sponsorName')} placeholder="Sponsor name" />
                {errors.sponsorName && (
                  <p className="text-sm text-destructive">{errors.sponsorName.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="title">Banner Title (optional)</Label>
                <Input id="title" {...register('title')} placeholder="Tap to learn more" />
                {errors.title && (
                  <p className="text-sm text-destructive">{errors.title.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="imageUrl">Banner Image URL</Label>
                <Input id="imageUrl" {...register('imageUrl')} placeholder="https://..." />
                {errors.imageUrl && (
                  <p className="text-sm text-destructive">{errors.imageUrl.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="redirectUrl">Redirect URL (optional)</Label>
                <Input id="redirectUrl" {...register('redirectUrl')} placeholder="https://..." />
                {errors.redirectUrl && (
                  <p className="text-sm text-destructive">{errors.redirectUrl.message}</p>
                )}
              </div>
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
                <Label htmlFor="priority">Priority (higher = shown first)</Label>
                <Input id="priority" type="number" min={0} {...register('priority')} />
                {errors.priority && (
                  <p className="text-sm text-destructive">{errors.priority.message}</p>
                )}
              </div>
            </div>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Creating...' : 'Create Sponsor'}
            </Button>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Sponsors ({sponsors.length})</CardTitle>
        </CardHeader>
        <CardContent>
          {sponsors.length === 0 ? (
            <p className="text-sm text-muted-foreground">No sponsors yet.</p>
          ) : (
            <ul className="divide-y">
              {sponsors.map((sponsor) => {
                const safeName =
                  typeof window !== 'undefined'
                    ? DOMPurify.sanitize(sponsor.name)
                    : sponsor.name;
                return (
                  <li key={sponsor.id} className="flex items-center gap-3 py-3">
                    {sponsor.logoUrl && (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={sponsor.logoUrl}
                        alt={safeName}
                        className="h-8 w-8 rounded object-contain border"
                      />
                    )}
                    <div className="flex-1 min-w-0">
                      <p
                        className="font-medium text-sm"
                        dangerouslySetInnerHTML={{ __html: safeName }}
                      />
                      {sponsor.contactEmail && (
                        <p className="text-xs text-muted-foreground truncate">
                          {sponsor.contactEmail}
                        </p>
                      )}
                    </div>
                    {sponsor.isActive !== undefined && (
                      <Badge variant={sponsor.isActive ? 'default' : 'secondary'}>
                        {sponsor.isActive ? 'Active' : 'Inactive'}
                      </Badge>
                    )}
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => openEdit(sponsor)}
                    >
                      <Pencil className="h-4 w-4" />
                    </Button>
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => setDeleteTarget(sponsor)}
                    >
                      <Trash2 className="h-4 w-4 text-destructive" />
                    </Button>
                  </li>
                );
              })}
            </ul>
          )}
        </CardContent>
      </Card>

      <ConfirmDialog
        open={!!deleteTarget}
        onOpenChange={(open) => !open && setDeleteTarget(null)}
        title="Delete Sponsor"
        description={`Delete sponsor "${deleteTarget?.name}"?`}
        confirmWord="DELETE"
        onConfirm={handleDelete}
        isPending={false}
        variant="destructive"
        confirmLabel="Delete"
      />

      <Dialog open={!!editTarget} onOpenChange={(open) => !open && setEditTarget(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Sponsor</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="e-sponsor-name">Sponsor Name</Label>
              <Input
                id="e-sponsor-name"
                value={editForm.sponsorName}
                onChange={(e) => setEditForm({ ...editForm, sponsorName: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="e-title">Title</Label>
              <Input
                id="e-title"
                value={editForm.title}
                onChange={(e) => setEditForm({ ...editForm, title: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="e-image">Image URL</Label>
              <Input
                id="e-image"
                value={editForm.imageUrl}
                onChange={(e) => setEditForm({ ...editForm, imageUrl: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="e-redirect">Redirect URL</Label>
              <Input
                id="e-redirect"
                value={editForm.redirectUrl}
                onChange={(e) => setEditForm({ ...editForm, redirectUrl: e.target.value })}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="e-priority">Priority</Label>
                <Input
                  id="e-priority"
                  type="number"
                  min={0}
                  value={editForm.priority}
                  onChange={(e) => setEditForm({ ...editForm, priority: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="e-active">Status</Label>
                <select
                  id="e-active"
                  className="w-full h-9 rounded-md border bg-background px-2 text-sm"
                  value={editForm.isActive}
                  onChange={(e) =>
                    setEditForm({ ...editForm, isActive: Number(e.target.value) as 0 | 1 })
                  }
                >
                  <option value={1}>Active</option>
                  <option value={0}>Inactive</option>
                </select>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditTarget(null)} disabled={isSavingEdit}>
              Cancel
            </Button>
            <Button onClick={handleEditSave} disabled={isSavingEdit}>
              {isSavingEdit ? 'Saving…' : 'Save'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
