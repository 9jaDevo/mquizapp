import { apiServer } from '@/lib/api-server';
import type { PaginatedData, Question } from '@/types/api';
import { QuestionsTable } from './questions-table';
import { Button } from '@/components/ui/button';
import Link from 'next/link';

async function getQuestions(page = 1, limit = 20): Promise<PaginatedData<Question>> {
  return apiServer.get<PaginatedData<Question>>(
    `/v2/admin/questions?page=${page}&limit=${limit}`,
    { tags: ['questions'], revalidate: 60 },
  );
}

export default async function QuestionsPage({
  searchParams,
}: {
  searchParams: Promise<{ page?: string }>;
}) {
  const params = await searchParams;
  const page = parseInt(params.page ?? '1', 10);

  let data: PaginatedData<Question> | null = null;
  let error: string | null = null;

  try {
    data = await getQuestions(page);
  } catch (e) {
    error = e instanceof Error ? e.message : 'Failed to load questions';
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Questions</h1>
          <p className="text-muted-foreground">Manage quiz questions</p>
        </div>
        <Button asChild>
          <Link href="/questions/new">Add Question</Link>
        </Button>
      </div>

      {error && (
        <div className="rounded-md bg-destructive/10 px-4 py-3 text-sm text-destructive">
          {error}
        </div>
      )}

      <QuestionsTable
        questions={data?.items ?? []}
        pageCount={data?.totalPages ?? 1}
        pageIndex={page - 1}
      />
    </div>
  );
}
