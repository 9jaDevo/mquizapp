'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ColumnDef } from '@tanstack/react-table';
import { toast } from 'sonner';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { DataTable } from '@/components/data-table';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { FraudFlag } from '@/types/api';

interface FraudFlagsTableProps {
  data: FraudFlag[];
  pageCount: number;
  pageIndex: number;
}

export function FraudFlagsTable({
  data,
  pageCount,
  pageIndex,
}: FraudFlagsTableProps) {
  const router = useRouter();
  const api = useApiClient();
  const [target, setTarget] = React.useState<FraudFlag | null>(null);
  const [isPending, setIsPending] = React.useState(false);

  async function handleResolve() {
    if (!target) return;
    setIsPending(true);
    try {
      await api.patch(`/v2/admin/fraud-flags/${target.id}/resolve`, {
        action: 'review',
      });
      toast.success('Flag resolved');
      router.refresh();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to resolve');
    } finally {
      setIsPending(false);
      setTarget(null);
    }
  }

  const columns: ColumnDef<FraudFlag>[] = [
    { accessorKey: 'id', header: 'ID', size: 70 },
    {
      id: 'user',
      header: 'User',
      cell: ({ row }) => {
        const uid = row.original.userId;
        return uid ? (
          <Link
            href={`/users/${uid}`}
            className="text-primary hover:underline"
          >
            #{uid}
          </Link>
        ) : (
          '—'
        );
      },
    },
    {
      id: 'type',
      header: 'Type',
      cell: ({ row }) =>
        row.original.detectionType ?? row.original.detection_type ?? '—',
    },
    {
      id: 'severity',
      header: 'Severity',
      cell: ({ row }) => {
        const s = row.original.severity ?? 'low';
        const variant =
          s === 'high'
            ? 'destructive'
            : s === 'medium'
              ? 'default'
              : 'secondary';
        return <Badge variant={variant}>{s}</Badge>;
      },
    },
    {
      accessorKey: 'reason',
      header: 'Reason',
      cell: ({ row }) => (
        <span className="line-clamp-2 max-w-md text-sm">
          {row.getValue('reason') ?? '—'}
        </span>
      ),
    },
    {
      accessorKey: 'resolved',
      header: 'Status',
      cell: ({ row }) => {
        const r = row.getValue<number>('resolved');
        return r ? (
          <Badge variant="secondary">Resolved</Badge>
        ) : (
          <Badge variant="destructive">Open</Badge>
        );
      },
    },
    {
      accessorKey: 'createdAt',
      header: 'When',
      cell: ({ row }) => {
        const v = row.getValue<string | null>('createdAt');
        return v ? new Date(v).toLocaleString() : '—';
      },
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) =>
        row.original.resolved ? null : (
          <Button size="sm" variant="outline" onClick={() => setTarget(row.original)}>
            Resolve
          </Button>
        ),
    },
  ];

  return (
    <>
      <DataTable
        columns={columns}
        data={data}
        pageCount={pageCount}
        pageIndex={pageIndex}
        pageSize={20}
        onPageChange={(p) => router.push(`/fraud-flags?page=${p + 1}`)}
      />
      <ConfirmDialog
        open={!!target}
        onOpenChange={(open) => !open && setTarget(null)}
        title="Resolve Fraud Flag"
        description={`Mark fraud flag #${target?.id} as resolved?`}
        onConfirm={handleResolve}
        isPending={isPending}
        confirmLabel="Resolve"
      />
    </>
  );
}
