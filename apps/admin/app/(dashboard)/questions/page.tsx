import Link from 'next/link';
import { apiServer } from '@/lib/api-server';
import type { Category, Question } from '@/types/api';
import { QuestionsTable } from './questions-table';

interface LegacyPaginated<T> {
  items: T[];
  pagination: { page: number; limit: number; total: number; pages: number };
}

async function getQuestions(params: {
  page: number;
  limit?: number;
  search?: string;
  categoryId?: number;
  difficulty?: number;
  isAi?: boolean;
}): Promise<LegacyPaginated<Question>> {
  const sp = new URLSearchParams();
  sp.set('page', String(params.page));
  sp.set('limit', String(params.limit ?? 20));
  if (params.search) sp.set('search', params.search);
  if (params.categoryId) sp.set('categoryId', String(params.categoryId));
  if (params.difficulty) sp.set('difficulty', String(params.difficulty));
  if (params.isAi !== undefined) sp.set('isAi', String(params.isAi));
  return apiServer.get<LegacyPaginated<Question>>(
    `/v2/admin/questions?${sp.toString()}`,
    { tags: ['questions'], revalidate: 60 },
  );
}

async function getCategories(): Promise<Category[]> {
  try {
    const res = await apiServer.get<{ items: Category[] }>('/v2/admin/categories', {
      tags: ['categories'],
      revalidate: 300,
    });
    return res.items ?? [];
  } catch {
    return [];
  }
}

export default async function QuestionsPage({
  searchParams,
}: {
  searchParams: Promise<{
    page?: string;
    search?: string;
    categoryId?: string;
    difficulty?: string;
    isAi?: string;
  }>;
}) {
  const params = await searchParams;
  const page = parseInt(params.page ?? '1', 10);
  const categoryId = params.categoryId ? parseInt(params.categoryId, 10) : undefined;
  const difficulty = params.difficulty ? parseInt(params.difficulty, 10) : undefined;
  const isAi =
    params.isAi === 'true' ? true : params.isAi === 'false' ? false : undefined;

  let data: LegacyPaginated<Question> | null = null;
  let error: string | null = null;
  const categories = await getCategories();

  try {
    data = await getQuestions({
      page,
      search: params.search,
      categoryId,
      difficulty,
      isAi,
    });
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
        <Link
          href="/questions/new"
          className="inline-flex h-8 items-center rounded-lg bg-primary px-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/80"
        >
          Add Question
        </Link>
      </div>

      {error && (
        <div className="rounded-md bg-destructive/10 px-4 py-3 text-sm text-destructive">
          {error}
        </div>
      )}

      <QuestionsTable
        questions={data?.items ?? []}
        categories={categories}
        pageCount={data?.pagination?.pages ?? 1}
        pageIndex={page - 1}
        initialSearch={params.search ?? ''}
        initialCategoryId={params.categoryId ?? ''}
        initialDifficulty={params.difficulty ?? ''}
        initialIsAi={params.isAi ?? ''}
      />
    </div>
  );
}
