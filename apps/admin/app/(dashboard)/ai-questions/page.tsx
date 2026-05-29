import { apiServer } from '@/lib/api-server';
import type { Category } from '@/types/api';
import { AiQuestionsPanel } from './ai-questions-panel';

async function getCategories(): Promise<Category[]> {
  const res = await apiServer.get<{ items: Category[] }>('/v2/admin/categories', {
    tags: ['categories'],
    revalidate: 300,
  });
  return res.items ?? [];
}

export default async function AiQuestionsPage() {
  let categories: Category[] = [];
  try {
    categories = await getCategories();
  } catch {
    // non-fatal
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">AI Question Generation</h1>
        <p className="text-muted-foreground">
          Generate quiz questions using GPT-4o
        </p>
      </div>
      <AiQuestionsPanel categories={categories} />
    </div>
  );
}
