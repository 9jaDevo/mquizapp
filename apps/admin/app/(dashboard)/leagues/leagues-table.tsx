'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ColumnDef } from '@tanstack/react-table';
import { toast } from 'sonner';
import { Badge } from '@/components/ui/badge';
import { Button, buttonVariants } from '@/components/ui/button';
import { DataTable } from '@/components/data-table';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { League } from '@/types/api';

interface LeaguesTableProps {
  data: League[];
  pageCount: number;
  pageIndex: number;
}

export function LeaguesTable({ data, pageCount, pageIndex }: LeaguesTableProps) {
  const router = useRouter();
  const api = useApiClient();
  const [distributeTarget, setDistributeTarget] = React.useState<League | null>(null);
  const [distributing, setDistributing] = React.useState(false);

  async function handleDistribute() {
    if (!distributeTarget) return;
    setDistributing(true);
    try {
      await api.post(`/v2/admin/leagues/${distributeTarget.id}/distribute-prizes`, {});
      toast.success(`Prizes distributed for ${distributeTarget.name}`);
      router.refresh();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to distribute prizes');
    } finally {
      setDistributing(false);
    }
  }

  const columns: ColumnDef<League>[] = [
    { accessorKey: 'id', header: 'ID', size: 70 },
    { accessorKey: 'name', header: 'Name' },
    { accessorKey: 'tier', header: 'Tier' },
    {
      accessorKey: 'season',
      header: 'Season',
      cell: ({ row }) => `Season ${row.getValue('season') ?? 1}`,
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => {
        const s: string = row.getValue('status');
        return (
          <Badge variant={s === 'active' ? 'default' : 'secondary'}>{s}</Badge>
        );
      },
    },
    {
      accessorKey: 'participantCount',
      header: 'Participants',
      cell: ({ row }) => (row.getValue('participantCount') as number)?.toLocaleString() ?? '—',
    },
    {
      id: 'prizes',
      header: 'Prizes',
      cell: ({ row }) => {
        const distributed = (row.original.prizeStatus ?? 0) === 1;
        return distributed ? (
          <Badge variant="default">Distributed</Badge>
        ) : (
          <Badge variant="outline">Pending</Badge>
        );
      },
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => {
        const distributed = (row.original.prizeStatus ?? 0) === 1;
        return (
          <div className="flex gap-2">
            <Link
              href={`/leagues/${row.original.id}/edit`}
              className={buttonVariants({ variant: 'outline', size: 'sm' })}
            >
              Edit
            </Link>
            {!distributed && (
              <Button
                size="sm"
                variant="secondary"
                onClick={() => setDistributeTarget(row.original)}
              >
                Distribute
              </Button>
            )}
          </div>
        );
      },
    },
  ];

  return (
    <>
      <DataTable
        columns={columns}
        data={data}
        searchColumn="name"
        searchPlaceholder="Search leagues..."
        pageCount={pageCount}
        pageIndex={pageIndex}
        pageSize={20}
        onPageChange={(p) => router.push(`/leagues?page=${p + 1}`)}
      />
      <ConfirmDialog
        open={distributeTarget !== null}
        onOpenChange={(o) => !o && setDistributeTarget(null)}
        title="Distribute league prizes"
        description={`This will mark prizes as distributed for "${distributeTarget?.name}". This action cannot be undone.`}
        confirmLabel="Distribute"
        confirmWord="DISTRIBUTE"
        onConfirm={handleDistribute}
        isPending={distributing}
      />
    </>
  );
}
