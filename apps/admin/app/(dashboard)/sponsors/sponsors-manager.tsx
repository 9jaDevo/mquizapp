'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import DOMPurify from 'dompurify';
import { Trash2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { Sponsor } from '@/types/api';

const schema = z.object({
  name: z.string().min(1, 'Name is required'),
  logoUrl: z.string().url('Must be a valid URL'),
  websiteUrl: z.string().url('Must be a valid URL').optional().or(z.literal('')),
  contactEmail: z.string().email('Must be a valid email').optional().or(z.literal('')),
});

type FormData = z.infer<typeof schema>;

interface SponsorsManagerProps {
  initialSponsors: Sponsor[];
}

export function SponsorsManager({ initialSponsors }: SponsorsManagerProps) {
  const api = useApiClient();
  const [sponsors, setSponsors] = React.useState<Sponsor[]>(initialSponsors);
  const [deleteTarget, setDeleteTarget] = React.useState<Sponsor | null>(null);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  async function onCreate(data: FormData) {
    try {
      const created = await api
        .post<Sponsor>('/v2/admin/sponsors', data)
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
                <Label htmlFor="name">Name</Label>
                <Input id="name" {...register('name')} placeholder="Sponsor name" />
                {errors.name && (
                  <p className="text-sm text-destructive">{errors.name.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="logoUrl">Logo URL</Label>
                <Input id="logoUrl" {...register('logoUrl')} placeholder="https://..." />
                {errors.logoUrl && (
                  <p className="text-sm text-destructive">{errors.logoUrl.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="websiteUrl">Website URL</Label>
                <Input id="websiteUrl" {...register('websiteUrl')} placeholder="https://..." />
                {errors.websiteUrl && (
                  <p className="text-sm text-destructive">{errors.websiteUrl.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="contactEmail">Contact Email</Label>
                <Input
                  id="contactEmail"
                  type="email"
                  {...register('contactEmail')}
                  placeholder="contact@sponsor.com"
                />
                {errors.contactEmail && (
                  <p className="text-sm text-destructive">{errors.contactEmail.message}</p>
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
    </>
  );
}
