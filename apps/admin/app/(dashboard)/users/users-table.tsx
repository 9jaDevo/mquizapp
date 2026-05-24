'use client';

import * as React from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { type ColumnDef } from '@tanstack/react-table';
import { DataTable } from '@/components/data-table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
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
      <Link
        href={`/users/${row.original.id}`}
        className="inline-flex h-7 items-center rounded-lg px-2.5 text-sm hover:bg-muted"
      >
        View
      </Link>
    ),
  },
];

interface UsersTableProps {
  users: User[];
  pageCount: number;
  pageIndex: number;
  initialStatus?: string;
  initialFirebaseId?: string;
}

export function UsersTable({
  users,
  pageCount,
  pageIndex,
  initialStatus = '',
  initialFirebaseId = '',
}: UsersTableProps) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [firebaseId, setFirebaseId] = React.useState(initialFirebaseId);

  function applyFilter(updates: Record<string, string | undefined>) {
    const sp = new URLSearchParams(searchParams.toString());
    for (const [k, v] of Object.entries(updates)) {
      if (!v) sp.delete(k);
      else sp.set(k, v);
    }
    sp.set('page', '1');
    router.push(`/users?${sp.toString()}`);
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end gap-3">
        {/* Firebase ID search */}
        <form
          onSubmit={(e) => {
            e.preventDefault();
            applyFilter({ firebaseId: firebaseId || undefined });
          }}
          className="flex gap-2"
        >
          <Input
            value={firebaseId}
            onChange={(e) => setFirebaseId(e.target.value)}
            placeholder="Search by Firebase UID..."
            className="w-64"
          />
          <Button type="submit" variant="outline" size="sm">
            Search
          </Button>
          {firebaseId && (
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => {
                setFirebaseId('');
                applyFilter({ firebaseId: undefined });
              }}
            >
              Clear
            </Button>
          )}
        </form>

        {/* Status filter */}
        <div className="w-36">
          <Select
            value={initialStatus || 'all'}
            onValueChange={(v) =>
              applyFilter({ status: !v || v === 'all' ? undefined : v })
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="All statuses" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All statuses</SelectItem>
              <SelectItem value="0">Active</SelectItem>
              <SelectItem value="1">Banned</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={users}
        searchPlaceholder="Search by name..."
        pageCount={pageCount}
        pageIndex={pageIndex}
        pageSize={20}
        onPageChange={(page) => {
          const sp = new URLSearchParams(searchParams.toString());
          sp.set('page', String(page + 1));
          router.push(`/users?${sp.toString()}`);
        }}
      />
    </div>
  );
}
