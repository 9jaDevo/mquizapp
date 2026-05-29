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
import type { CoinPack } from '@/types/api';

const schema = z.object({
  title: z.string().min(1, 'Title is required').max(50),
  coins: z.coerce.number().int().min(1, 'Coins must be at least 1'),
  priceKobo: z.coerce.number().int().min(0, 'Price cannot be negative'),
  productId: z.string().max(150).optional().or(z.literal('')),
  imageUrl: z
    .string()
    .url('Must be a valid URL')
    .max(500)
    .optional()
    .or(z.literal('')),
  description: z.string().max(2000).optional().or(z.literal('')),
});

type FormInput = z.input<typeof schema>;
type FormData = z.output<typeof schema>;

interface Props {
  initialPacks: CoinPack[];
}

function formatNaira(kobo: number): string {
  return `\u20a6${(kobo / 100).toLocaleString('en-NG', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
}

export function CoinStoreManager({ initialPacks }: Props) {
  const api = useApiClient();
  const [packs, setPacks] = React.useState<CoinPack[]>(initialPacks);
  const [deleteTarget, setDeleteTarget] = React.useState<CoinPack | null>(null);
  const [editTarget, setEditTarget] = React.useState<CoinPack | null>(null);
  const [editForm, setEditForm] = React.useState({
    title: '',
    coins: '0',
    priceKobo: '0',
    productId: '',
    imageUrl: '',
    description: '',
  });
  const [isSavingEdit, setIsSavingEdit] = React.useState(false);
  const [isDeleting, setIsDeleting] = React.useState(false);

  function openEdit(pack: CoinPack) {
    setEditTarget(pack);
    setEditForm({
      title: pack.title,
      coins: String(pack.coins),
      priceKobo: String(pack.priceKobo),
      productId: pack.productId ?? '',
      imageUrl: pack.image ?? '',
      description: pack.description ?? '',
    });
  }

  async function handleEditSave() {
    if (!editTarget) return;
    setIsSavingEdit(true);
    try {
      const payload = {
        title: editForm.title,
        coins: Math.max(1, Math.floor(Number(editForm.coins) || 0)),
        priceKobo: Math.max(0, Math.floor(Number(editForm.priceKobo) || 0)),
        productId: editForm.productId || undefined,
        imageUrl: editForm.imageUrl || undefined,
        description: editForm.description || undefined,
      };
      const updated = await api
        .patch<CoinPack>(`/v2/admin/coin-store/${editTarget.id}`, payload)
        .then((r) => r.data as CoinPack);
      setPacks((prev) =>
        prev.map((p) => (p.id === editTarget.id ? { ...p, ...updated } : p)),
      );
      toast.success('Coin pack updated');
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
        title: data.title,
        coins: data.coins,
        priceKobo: data.priceKobo,
        productId: data.productId || undefined,
        imageUrl: data.imageUrl || undefined,
        description: data.description || undefined,
      };
      const created = await api
        .post<CoinPack>('/v2/admin/coin-store', payload)
        .then((r) => r.data as CoinPack);
      setPacks((prev) => [created, ...prev]);
      reset();
      toast.success('Coin pack created');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to create coin pack');
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    setIsDeleting(true);
    try {
      await api.delete(`/v2/admin/coin-store/${deleteTarget.id}`);
      setPacks((prev) =>
        prev.map((p) =>
          p.id === deleteTarget.id ? { ...p, status: 0 } : p,
        ),
      );
      toast.success('Coin pack deactivated');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete coin pack');
    } finally {
      setIsDeleting(false);
      setDeleteTarget(null);
    }
  }

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Add Coin Pack</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onCreate)} className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="title">Title</Label>
                <Input id="title" {...register('title')} placeholder="Starter Pack" />
                {errors.title && (
                  <p className="text-sm text-destructive">{errors.title.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="coins">Coins</Label>
                <Input id="coins" type="number" min={1} {...register('coins')} />
                {errors.coins && (
                  <p className="text-sm text-destructive">{errors.coins.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="priceKobo">Price (kobo)</Label>
                <Input
                  id="priceKobo"
                  type="number"
                  min={0}
                  {...register('priceKobo')}
                  placeholder="50000 = \u20a6500.00"
                />
                {errors.priceKobo && (
                  <p className="text-sm text-destructive">{errors.priceKobo.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="productId">IAP Product ID (optional)</Label>
                <Input
                  id="productId"
                  {...register('productId')}
                  placeholder="com.mquiz.coins.starter"
                />
                {errors.productId && (
                  <p className="text-sm text-destructive">{errors.productId.message}</p>
                )}
              </div>
              <div className="space-y-2 sm:col-span-2">
                <Label htmlFor="imageUrl">Image URL (optional)</Label>
                <Input id="imageUrl" {...register('imageUrl')} placeholder="https://..." />
                {errors.imageUrl && (
                  <p className="text-sm text-destructive">{errors.imageUrl.message}</p>
                )}
              </div>
              <div className="space-y-2 sm:col-span-2">
                <Label htmlFor="description">Description (optional)</Label>
                <Input
                  id="description"
                  {...register('description')}
                  placeholder="100 coins to boost your gameplay"
                />
                {errors.description && (
                  <p className="text-sm text-destructive">{errors.description.message}</p>
                )}
              </div>
            </div>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Creating...' : 'Create Coin Pack'}
            </Button>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Coin Packs ({packs.length})</CardTitle>
        </CardHeader>
        <CardContent>
          {packs.length === 0 ? (
            <p className="text-sm text-muted-foreground">No coin packs yet.</p>
          ) : (
            <ul className="divide-y">
              {packs.map((pack) => (
                <li key={pack.id} className="flex items-center gap-3 py-3">
                  {pack.image && (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={pack.image}
                      alt={pack.title}
                      className="h-10 w-10 rounded object-contain border"
                    />
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-sm truncate">{pack.title}</p>
                    <p className="text-xs text-muted-foreground truncate">
                      {pack.coins.toLocaleString()} coins &middot;{' '}
                      {formatNaira(pack.priceKobo)} &middot; {pack.productId}
                    </p>
                  </div>
                  <Badge variant={pack.status === 1 ? 'default' : 'secondary'}>
                    {pack.status === 1 ? 'Active' : 'Inactive'}
                  </Badge>
                  <Button size="icon" variant="ghost" onClick={() => openEdit(pack)}>
                    <Pencil className="h-4 w-4" />
                  </Button>
                  <Button
                    size="icon"
                    variant="ghost"
                    onClick={() => setDeleteTarget(pack)}
                    disabled={pack.status === 0}
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
        title="Deactivate Coin Pack"
        description={`Deactivate "${deleteTarget?.title}"? It will be hidden from the mobile store but past purchase history is preserved.`}
        confirmWord="DEACTIVATE"
        onConfirm={handleDelete}
        isPending={isDeleting}
        variant="destructive"
        confirmLabel="Deactivate"
      />

      <Dialog
        open={!!editTarget}
        onOpenChange={(open) => !open && setEditTarget(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Coin Pack</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="edit-title">Title</Label>
              <Input
                id="edit-title"
                value={editForm.title}
                onChange={(e) => setEditForm((p) => ({ ...p, title: e.target.value }))}
              />
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="edit-coins">Coins</Label>
                <Input
                  id="edit-coins"
                  type="number"
                  min={1}
                  value={editForm.coins}
                  onChange={(e) =>
                    setEditForm((p) => ({ ...p, coins: e.target.value }))
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="edit-price">Price (kobo)</Label>
                <Input
                  id="edit-price"
                  type="number"
                  min={0}
                  value={editForm.priceKobo}
                  onChange={(e) =>
                    setEditForm((p) => ({ ...p, priceKobo: e.target.value }))
                  }
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-product">IAP Product ID</Label>
              <Input
                id="edit-product"
                value={editForm.productId}
                onChange={(e) =>
                  setEditForm((p) => ({ ...p, productId: e.target.value }))
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-image">Image URL</Label>
              <Input
                id="edit-image"
                value={editForm.imageUrl}
                onChange={(e) =>
                  setEditForm((p) => ({ ...p, imageUrl: e.target.value }))
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-desc">Description</Label>
              <Input
                id="edit-desc"
                value={editForm.description}
                onChange={(e) =>
                  setEditForm((p) => ({ ...p, description: e.target.value }))
                }
              />
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
