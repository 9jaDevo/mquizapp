import { apiServer } from '@/lib/api-server';
import type { Category } from '@/types/api';
import { CategoriesManager } from './categories-manager';

async function getCategories(): Promise<Category[]> {
  const data = await apiServer.get<{ items: Category[] } | Category[]>(
    '/v2/admin/categories',
    { tags: ['categories'], revalidate: 60 },
  );
  if (Array.isArray(data)) return data;
  return data.items ?? [];
}

export default async function CategoriesPage() {
  let categories: Category[] = [];
  try {
    categories = await getCategories();
  } catch {
    // render empty state
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Categories</h1>
        <p className="text-muted-foreground">Manage quiz categories</p>
      </div>
      <CategoriesManager initialCategories={categories} />
    </div>
  );
}
