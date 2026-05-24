import { notFound } from 'next/navigation';
import { apiServer } from '@/lib/api-server';
import type { Category, Question } from '@/types/api';
import { QuestionForm } from '../../question-form';

async function getCategories(): Promise<Category[]> {
  return apiServer.get<Category[]>('/v2/categories', {
    tags: ['categories'],
    revalidate: 300,
  });
}

async function getQuestion(id: number): Promise<Question | null> {
  try {
    return await apiServer.get<Question>(`/v2/admin/questions/${id}`, {
      tags: [`question-${id}`],
    });
  } catch {
    return null;
  }
}

export default async function EditQuestionPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id: idStr } = await params;
  const id = parseInt(idStr, 10);
  if (Number.isNaN(id)) notFound();

  const [question, categories] = await Promise.all([
    getQuestion(id),
    getCategories().catch(() => [] as Category[]),
  ]);

  if (!question) notFound();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Edit Question</h1>
        <p className="text-muted-foreground">Update question #{question.id}</p>
      </div>
      <QuestionForm categories={categories} question={question} />
    </div>
  );
}
