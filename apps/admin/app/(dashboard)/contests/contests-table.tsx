'use client';

import * as React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ColumnDef } from '@tanstack/react-table';
import { toast } from 'sonner';
import { Badge } from '@/components/ui/badge';
import { Button, buttonVariants } from '@/components/ui/button';
import { DataTable } from '@/components/data-table';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { Contest } from '@/types/api';

interface ContestsTableProps {
  data: Contest[];
  pageCount: number;
  pageIndex: number;
}

export function ContestsTable({ data, pageCount, pageIndex }: ContestsTableProps) {
  const router = useRouter();
  const api = useApiClient();
  const [distributeTarget, setDistributeTarget] = React.useState<Contest | null>(null);
  const [isPending, setIsPending] = React.useState(false);

  async function handleDistribute() {
    if (!distributeTarget) return;
    setIsPending(true);
    try {
      await api.post(`/v2/admin/contests/${distributeTarget.id}/distribute`, {});
      toast.success('Prizes distributed');
      router.refresh();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Distribution failed');
    } finally {
      setIsPending(false);
      setDistributeTarget(null);
    }
  }

  const columns: ColumnDef<Contest>[] = [
    { accessorKey: 'id', header: 'ID', size: 70 },
    { accessorKey: 'title', header: 'Title' },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => {
        const s: string = row.getValue('status');
        const variant =
          s === 'active' ? 'default' : s === 'ended' ? 'secondary' : 'outline';
        return <Badge variant={variant}>{s}</Badge>;
      },
    },
    {
      accessorKey: 'prizePool',
      header: 'Prize Pool',
      cell: ({ row }) => `₦${Number(row.getValue('prizePool') ?? 0).toLocaleString()}`,
    },
    {
      accessorKey: 'startDate',
      header: 'Start',
      cell: ({ row }) =>
        row.getValue('startDate')
          ? new Date(row.getValue('startDate')).toLocaleDateString()
          : '—',
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => {
        const contest = row.original;
        return (
          <div className="flex gap-2">
            <Link
              href={`/contests/${contest.id}/edit`}
              className={buttonVariants({ variant: 'outline', size: 'sm' })}
            >
              Edit
            </Link>
            <Link
              href={`/contests/${contest.id}/questions`}
              className={buttonVariants({ variant: 'outline', size: 'sm' })}
            >
              Questions
            </Link>
            {contest.status === 'ended' && (
              <Button
                size="sm"
                variant="outline"
                onClick={() => setDistributeTarget(contest)}
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
        searchColumn="title"
        searchPlaceholder="Search contests..."
        pageCount={pageCount}
        pageIndex={pageIndex}
        pageSize={20}
        onPageChange={(p) => router.push(`/contests?page=${p + 1}`)}
      />
      <ConfirmDialog
        open={!!distributeTarget}
        onOpenChange={(open) => !open && setDistributeTarget(null)}
        title="Distribute Prizes"
        description={`Distribute prizes for "${distributeTarget?.title}"? This action cannot be undone.`}
        confirmWord="DISTRIBUTE"
        onConfirm={handleDistribute}
        isPending={isPending}
        variant="default"
        confirmLabel="Distribute"
      />
    </>
  );
}
