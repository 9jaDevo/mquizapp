'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
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
import type { ProgressStage } from '@/types/api';

const schema = z.object({
  stageNumber: z.coerce.number().int().min(1, 'Stage number must be at least 1'),
  name: z.string().min(1, 'Name is required').max(128),
  minScore: z.coerce.number().int().min(0, 'Min score cannot be negative'),
  iconUrl: z
    .string()
    .url('Must be a valid URL')
    .max(500)
    .optional()
    .or(z.literal('')),
});

type FormInput = z.input<typeof schema>;
type FormData = z.output<typeof schema>;

interface Props {
  initialStages: ProgressStage[];
}

export function StagesManager({ initialStages }: Props) {
  const api = useApiClient();
  const [stages, setStages] = React.useState<ProgressStage[]>(initialStages);
  const [deleteTarget, setDeleteTarget] = React.useState<ProgressStage | null>(null);
  const [editTarget, setEditTarget] = React.useState<ProgressStage | null>(null);
  const [editForm, setEditForm] = React.useState({
    stageNumber: '1',
    name: '',
    minScore: '0',
    iconUrl: '',
    isActive: true,
  });
  const [isSavingEdit, setIsSavingEdit] = React.useState(false);
  const [isDeleting, setIsDeleting] = React.useState(false);

  function openEdit(stage: ProgressStage) {
    setEditTarget(stage);
    setEditForm({
      stageNumber: String(stage.stageNumber),
      name: stage.name,
      minScore: String(stage.minScore),
      iconUrl: stage.iconUrl ?? '',
      isActive: stage.isActive,
    });
  }

  async function handleEditSave() {
    if (!editTarget) return;
    setIsSavingEdit(true);
    try {
      const payload = {
        stageNumber: Math.max(1, Math.floor(Number(editForm.stageNumber) || 0)),
        name: editForm.name,
        minScore: Math.max(0, Math.floor(Number(editForm.minScore) || 0)),
        iconUrl: editForm.iconUrl || undefined,
        isActive: editForm.isActive,
      };
      const updated = await api
        .patch<ProgressStage>(
          `/v2/admin/progress-stages/${editTarget.id}`,
          payload,
        )
        .then((r) => r.data as ProgressStage);
      setStages((prev) =>
        prev
          .map((s) => (s.id === editTarget.id ? { ...s, ...updated } : s))
          .sort((a, b) => a.stageNumber - b.stageNumber),
      );
      toast.success('Stage updated');
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
  } = useForm<FormInput, unknown, FormData>({ resolver: zodResolver(schema) });

  async function onCreate(data: FormData) {
    try {
      const payload = {
        stageNumber: data.stageNumber,
        name: data.name,
        minScore: data.minScore,
        iconUrl: data.iconUrl || undefined,
        isActive: true,
      };
      const created = await api
        .post<ProgressStage>('/v2/admin/progress-stages', payload)
        .then((r) => r.data as ProgressStage);
      setStages((prev) =>
        [created, ...prev].sort((a, b) => a.stageNumber - b.stageNumber),
      );
      reset();
      toast.success('Stage created');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to create stage');
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    setIsDeleting(true);
    try {
      await api.delete(`/v2/admin/progress-stages/${deleteTarget.id}`);
      setStages((prev) => prev.filter((s) => s.id !== deleteTarget.id));
      toast.success('Stage deleted');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete stage');
    } finally {
      setIsDeleting(false);
      setDeleteTarget(null);
    }
  }

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Add Progress Stage</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onCreate)} className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="stageNumber">Stage Number</Label>
                <Input
                  id="stageNumber"
                  type="number"
                  min={1}
                  {...register('stageNumber')}
                />
                {errors.stageNumber && (
                  <p className="text-sm text-destructive">
                    {errors.stageNumber.message}
                  </p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="name">Name</Label>
                <Input id="name" {...register('name')} placeholder="Bronze" />
                {errors.name && (
                  <p className="text-sm text-destructive">{errors.name.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="minScore">Minimum XP / Score</Label>
                <Input
                  id="minScore"
                  type="number"
                  min={0}
                  {...register('minScore')}
                />
                {errors.minScore && (
                  <p className="text-sm text-destructive">{errors.minScore.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="iconUrl">Icon URL (optional)</Label>
                <Input id="iconUrl" {...register('iconUrl')} placeholder="https://..." />
                {errors.iconUrl && (
                  <p className="text-sm text-destructive">{errors.iconUrl.message}</p>
                )}
              </div>
            </div>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Creating...' : 'Create Stage'}
            </Button>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Progress Stages ({stages.length})</CardTitle>
        </CardHeader>
        <CardContent>
          {stages.length === 0 ? (
            <p className="text-sm text-muted-foreground">No stages yet.</p>
          ) : (
            <ul className="divide-y">
              {stages.map((stage) => (
                <li key={stage.id} className="flex items-center gap-3 py-3">
                  {stage.iconUrl && (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={stage.iconUrl}
                      alt={stage.name}
                      className="h-8 w-8 rounded object-contain border"
                    />
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-sm truncate">
                      #{stage.stageNumber} &middot; {stage.name}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      Min score: {stage.minScore.toLocaleString()}
                    </p>
                  </div>
                  <Badge variant={stage.isActive ? 'default' : 'secondary'}>
                    {stage.isActive ? 'Active' : 'Inactive'}
                  </Badge>
                  <Button size="icon" variant="ghost" onClick={() => openEdit(stage)}>
                    <Pencil className="h-4 w-4" />
                  </Button>
                  <Button
                    size="icon"
                    variant="ghost"
                    onClick={() => setDeleteTarget(stage)}
                  >
                    <Trash2 className="h-4 w-4 text-destructive" />
                  </Button>
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>

      <ConfirmDialog
        open={!!deleteTarget}
        onOpenChange={(open) => !open && setDeleteTarget(null)}
        title="Delete Progress Stage"
        description={`Permanently delete stage "${deleteTarget?.name}" (#${deleteTarget?.stageNumber})?`}
        confirmWord="DELETE"
        onConfirm={handleDelete}
        isPending={isDeleting}
        variant="destructive"
        confirmLabel="Delete"
      />

      <Dialog
        open={!!editTarget}
        onOpenChange={(open) => !open && setEditTarget(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Progress Stage</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="edit-stage-num">Stage Number</Label>
                <Input
                  id="edit-stage-num"
                  type="number"
                  min={1}
                  value={editForm.stageNumber}
                  onChange={(e) =>
                    setEditForm((p) => ({ ...p, stageNumber: e.target.value }))
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="edit-stage-name">Name</Label>
                <Input
                  id="edit-stage-name"
                  value={editForm.name}
                  onChange={(e) =>
                    setEditForm((p) => ({ ...p, name: e.target.value }))
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="edit-stage-score">Min Score</Label>
                <Input
                  id="edit-stage-score"
                  type="number"
                  min={0}
                  value={editForm.minScore}
                  onChange={(e) =>
                    setEditForm((p) => ({ ...p, minScore: e.target.value }))
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="edit-stage-icon">Icon URL</Label>
                <Input
                  id="edit-stage-icon"
                  value={editForm.iconUrl}
                  onChange={(e) =>
                    setEditForm((p) => ({ ...p, iconUrl: e.target.value }))
                  }
                />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <input
                id="edit-stage-active"
                type="checkbox"
                checked={editForm.isActive}
                onChange={(e) =>
                  setEditForm((p) => ({ ...p, isActive: e.target.checked }))
                }
              />
              <Label htmlFor="edit-stage-active">Active</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditTarget(null)}>
              Cancel
            </Button>
            <Button onClick={handleEditSave} disabled={isSavingEdit}>
              {isSavingEdit ? 'Saving...' : 'Save'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
