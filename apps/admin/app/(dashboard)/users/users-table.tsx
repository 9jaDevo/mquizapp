'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { type ColumnDef } from '@tanstack/react-table';
import { DataTable } from '@/components/data-table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import type { User } from '@/types/api';
import Link from 'next/link';

const columns: ColumnDef<User>[] = [
  { accessorKey: 'id', header: 'ID', size: 60 },
  { accessorKey: 'name', header: 'Name', enableSorting: true },
  { accessorKey: 'email', header: 'Email', enableSorting: true },
  {
    accessorKey: 'coins',
    header: 'Coins',
    enableSorting: true,
    cell: ({ getValue }) => (getValue<number>() ?? 0).toLocaleString(),
  },
  {
    accessorKey: 'isBanned',
    header: 'Status',
    cell: ({ getValue }) =>
      getValue<boolean>() ? (
        <Badge variant="destructive">Banned</Badge>
      ) : (
        <Badge variant="secondary">Active</Badge>
      ),
  },
  {
    id: 'actions',
    header: 'Actions',
    cell: ({ row }) => (
      <Button asChild variant="ghost" size="sm">
        <Link href={`/users/${row.original.id}`}>View</Link>
      </Button>
    ),
  },
];

interface UsersTableProps {
  users: User[];
  pageCount: number;
  pageIndex: number;
}

export function UsersTable({ users, pageCount, pageIndex }: UsersTableProps) {
  const router = useRouter();

  return (
    <DataTable
      columns={columns}
      data={users}
      searchPlaceholder="Search by name..."
      pageCount={pageCount}
      pageIndex={pageIndex}
      pageSize={20}
      onPageChange={(page) => router.push(`/users?page=${page + 1}`)}
    />
  );
}
