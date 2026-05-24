'use client';

import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ColumnDef } from '@tanstack/react-table';
import { Badge } from '@/components/ui/badge';
import { buttonVariants } from '@/components/ui/button';
import { DataTable } from '@/components/data-table';
import type { League } from '@/types/api';

interface LeaguesTableProps {
  data: League[];
  pageCount: number;
  pageIndex: number;
}

export function LeaguesTable({ data, pageCount, pageIndex }: LeaguesTableProps) {
  const router = useRouter();

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
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => (
        <Link
          href={`/leagues/${row.original.id}/edit`}
          className={buttonVariants({ variant: 'outline', size: 'sm' })}
        >
          Edit
        </Link>
      ),
    },
  ];

  return (
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
  );
}
