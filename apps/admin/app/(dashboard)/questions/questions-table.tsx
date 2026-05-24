'use client';

import * as React from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { type ColumnDef } from '@tanstack/react-table';
import { DataTable } from '@/components/data-table';
import { Badge } from '@/components/ui/badge';
import { Button, buttonVariants } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { toast } from 'sonner';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { Category, Question } from '@/types/api';

function LevelBadge({ level }: { level: number }) {
  const variant =
    level <= 3 ? 'secondary' : level <= 6 ? 'default' : 'destructive';
  return <Badge variant={variant}>L{level}</Badge>;
}

function QuestionsActions({ question }: { question: Question }) {
  const api = useApiClient();
  const router = useRouter();
  const [showDelete, setShowDelete] = React.useState(false);
  const [isPending, setIsPending] = React.useState(false);

  async function handleDelete() {
    setIsPending(true);
    try {
      await api.delete(`/v2/admin/questions/${question.id}`);
      toast.success('Question deleted');
      router.refresh();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete');
    } finally {
      setIsPending(false);
    }
  }

  return (
    <div className="flex gap-2">
      <Link
        href={`/questions/${question.id}/edit`}
        className={buttonVariants({ variant: 'outline', size: 'sm' })}
      >
        Edit
      </Link>
      <Button
        variant="ghost"
        size="sm"
        className="text-destructive hover:text-destructive"
        onClick={() => setShowDelete(true)}
      >
        Delete
      </Button>
      <ConfirmDialog
        open={showDelete}
        onOpenChange={setShowDelete}
        title="Delete Question?"
        description="This will permanently delete the question and cannot be undone."
        confirmWord="DELETE"
        variant="destructive"
        confirmLabel="Delete"
        onConfirm={handleDelete}
        isPending={isPending}
      />
    </div>
  );
}

const columns: ColumnDef<Question>[] = [
  { accessorKey: 'id', header: 'ID', size: 60 },
  {
    accessorKey: 'question',
    header: 'Question',
    cell: ({ getValue }) => (
      <span className="line-clamp-2 max-w-md">{getValue<string>()}</span>
    ),
  },
  { accessorKey: 'category', header: 'Category', size: 90 },
  {
    accessorKey: 'level',
    header: 'Level',
    cell: ({ getValue }) => <LevelBadge level={getValue<number>()} />,
    size: 80,
  },
  {
    accessorKey: 'answer',
    header: 'Ans',
    size: 60,
    cell: ({ getValue }) => (
      <Badge variant="outline">{getValue<string>().toUpperCase()}</Badge>
    ),
  },
  {
    id: 'actions',
    header: 'Actions',
    cell: ({ row }) => <QuestionsActions question={row.original} />,
  },
];

interface QuestionsTableProps {
  questions: Question[];
  categories: Category[];
  pageCount: number;
  pageIndex: number;
  initialSearch?: string;
  initialCategoryId?: string;
  initialDifficulty?: string;
}

export function QuestionsTable({
  questions,
  categories,
  pageCount,
  pageIndex,
  initialSearch = '',
  initialCategoryId = '',
  initialDifficulty = '',
}: QuestionsTableProps) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [search, setSearch] = React.useState(initialSearch);

  function applyFilter(updates: Record<string, string | undefined>) {
    const sp = new URLSearchParams(searchParams.toString());
    for (const [k, v] of Object.entries(updates)) {
      if (v === undefined || v === '') sp.delete(k);
      else sp.set(k, v);
    }
    sp.set('page', '1');
    router.push(`/questions?${sp.toString()}`);
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end gap-3">
        <form
          onSubmit={(e) => {
            e.preventDefault();
            applyFilter({ search: search || undefined });
          }}
          className="flex gap-2"
        >
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search questions..."
            className="w-64"
          />
          <Button type="submit" variant="outline" size="sm">
            Search
          </Button>
        </form>

        <div className="w-48">
          <Select
            value={initialCategoryId || 'all'}
            onValueChange={(v) =>
              applyFilter({ categoryId: !v || v === 'all' ? undefined : v })
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="All categories" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All categories</SelectItem>
              {categories.map((c) => (
                <SelectItem key={c.id} value={String(c.id)}>
                  {c.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="w-40">
          <Select
            value={initialDifficulty || 'all'}
            onValueChange={(v) =>
              applyFilter({ difficulty: !v || v === 'all' ? undefined : v })
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="All levels" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All levels</SelectItem>
              <SelectItem value="1">Easy (1)</SelectItem>
              <SelectItem value="2">Medium (2)</SelectItem>
              <SelectItem value="3">Hard (3)</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={questions}
        pageCount={pageCount}
        pageIndex={pageIndex}
        pageSize={20}
        onPageChange={(page) => {
          const sp = new URLSearchParams(searchParams.toString());
          sp.set('page', String(page + 1));
          router.push(`/questions?${sp.toString()}`);
        }}
      />
    </div>
  );
}
