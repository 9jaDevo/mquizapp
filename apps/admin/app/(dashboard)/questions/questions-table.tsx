'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { type ColumnDef } from '@tanstack/react-table';
import { DataTable } from '@/components/data-table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { Question } from '@/types/api';

function DifficultyBadge({ level }: { level: string }) {
  const variant =
    level === 'easy'
      ? 'secondary'
      : level === 'medium'
      ? 'default'
      : 'destructive';
  return <Badge variant={variant}>{level}</Badge>;
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
    <>
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
    </>
  );
}

const columns: ColumnDef<Question>[] = [
  { accessorKey: 'id', header: 'ID', size: 60 },
  {
    accessorKey: 'questionText',
    header: 'Question',
    cell: ({ getValue }) => (
      <span className="line-clamp-2 max-w-xs">{getValue<string>()}</span>
    ),
  },
  {
    accessorKey: 'difficultyLevel',
    header: 'Difficulty',
    cell: ({ getValue }) => <DifficultyBadge level={getValue<string>()} />,
  },
  {
    accessorKey: 'isActive',
    header: 'Status',
    cell: ({ getValue }) =>
      getValue<boolean>() ? (
        <Badge variant="secondary">Active</Badge>
      ) : (
        <Badge variant="outline">Inactive</Badge>
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
  pageCount: number;
  pageIndex: number;
}

export function QuestionsTable({ questions, pageCount, pageIndex }: QuestionsTableProps) {
  const router = useRouter();

  return (
    <DataTable
      columns={columns}
      data={questions}
      searchPlaceholder="Search questions..."
      pageCount={pageCount}
      pageIndex={pageIndex}
      pageSize={20}
      onPageChange={(page) => router.push(`/questions?page=${page + 1}`)}
    />
  );
}
