import { apiServer } from '@/lib/api-server';
import type { Category } from '@/types/api';
import { QuestionForm } from '../question-form';

async function getCategories(): Promise<Category[]> {
  const res = await apiServer.get<{ items: Category[] }>('/v2/admin/categories', {
    tags: ['categories'],
    revalidate: 300,
  });
  return res.items ?? [];
}

export default async function NewQuestionPage() {
  let categories: Category[] = [];

  try {
    categories = await getCategories();
  } catch {
    // non-fatal — form will show empty categories list
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Add Question</h1>
        <p className="text-muted-foreground">Create a new quiz question</p>
      </div>
      <QuestionForm categories={categories} />
    </div>
  );
}
