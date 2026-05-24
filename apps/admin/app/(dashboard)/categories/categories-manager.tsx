'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import {
  GripVertical,
  Plus,
  Trash2,
  Pencil,
  Star,
  ChevronDown,
  ChevronRight,
  Eye,
  EyeOff,
} from 'lucide-react';
import {
  DndContext,
  closestCenter,
  PointerSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
} from '@dnd-kit/core';
import {
  SortableContext,
  verticalListSortingStrategy,
  useSortable,
  arrayMove,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { useApiClient } from '@/hooks/use-api-client';
import type { Category, Subcategory } from '@/types/api';

// ---------------------------------------------------------------------------
// Subcategory Panel
// ---------------------------------------------------------------------------
function SubcategoryPanel({ categoryId }: { categoryId: number }) {
  const api = useApiClient();
  const [subs, setSubs] = React.useState<Subcategory[] | null>(null);
  const [loading, setLoading] = React.useState(false);
  const [newName, setNewName] = React.useState('');
  const [editingId, setEditingId] = React.useState<number | null>(null);
  const [editName, setEditName] = React.useState('');
  const [deleteTarget, setDeleteTarget] = React.useState<Subcategory | null>(null);

  React.useEffect(() => {
    setLoading(true);
    api
      .get(`/v2/admin/categories/${categoryId}/subcategories`)
      .then((r) => {
        const d = r.data as { items: Subcategory[] } | Subcategory[];
        setSubs(Array.isArray(d) ? d : (d as { items: Subcategory[] }).items ?? []);
      })
      .catch(() => setSubs([]))
      .finally(() => setLoading(false));
  }, [categoryId]);

  async function handleCreate() {
    const name = newName.trim();
    if (!name) return;
    try {
      const created = await api
        .post(`/v2/admin/categories/${categoryId}/subcategories`, { name })
        .then((r) => r.data as Subcategory);
      setSubs((prev) => [...(prev ?? []), created]);
      setNewName('');
      toast.success('Subcategory created');
    } catch {
      toast.error('Failed to create subcategory');
    }
  }

  async function handleUpdate(id: number) {
    const name = editName.trim();
    if (!name) return;
    try {
      await api.patch(`/v2/admin/categories/subcategories/${id}`, { name });
      setSubs((prev) => prev?.map((s) => (s.id === id ? { ...s, name } : s)) ?? null);
      setEditingId(null);
      toast.success('Subcategory updated');
    } catch {
      toast.error('Failed to update subcategory');
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    try {
      await api.delete(`/v2/admin/categories/subcategories/${deleteTarget.id}`);
      setSubs((prev) => prev?.filter((s) => s.id !== deleteTarget.id) ?? null);
      toast.success('Subcategory deleted');
    } catch {
      toast.error('Failed to delete subcategory');
    } finally {
      setDeleteTarget(null);
    }
  }

  async function handleToggleStatus(sub: Subcategory) {
    const newStatus = sub.status === 1 ? 0 : 1;
    try {
      await api.patch(`/v2/admin/categories/subcategories/${sub.id}`, { status: newStatus });
      setSubs((prev) => prev?.map((s) => (s.id === sub.id ? { ...s, status: newStatus } : s)) ?? null);
    } catch {
      toast.error('Failed to update status');
    }
  }

  async function handleTogglePremium(sub: Subcategory) {
    const newVal = sub.isPremium === 1 ? 0 : 1;
    try {
      await api.patch(`/v2/admin/categories/subcategories/${sub.id}`, { isPremium: newVal });
      setSubs((prev) => prev?.map((s) => (s.id === sub.id ? { ...s, isPremium: newVal } : s)) ?? null);
    } catch {
      toast.error('Failed to update premium');
    }
  }

  if (loading) return <p className="text-xs text-muted-foreground py-2">Loading subcategories…</p>;

  return (
    <div className="pl-8 pb-3 space-y-2">
      <div className="flex gap-2">
        <Input
          value={newName}
          onChange={(e) => setNewName(e.target.value)}
          placeholder="New subcategory name"
          className="h-7 text-xs"
          onKeyDown={(e) => e.key === 'Enter' && handleCreate()}
        />
        <Button size="sm" onClick={handleCreate} disabled={!newName.trim()}>
          <Plus className="h-3 w-3 mr-1" />
          Add
        </Button>
      </div>

      {(subs ?? []).length === 0 ? (
        <p className="text-xs text-muted-foreground">No subcategories.</p>
      ) : (
        <ul className="divide-y border rounded-md">
          {(subs ?? []).map((sub) => (
            <li key={sub.id} className="flex items-center gap-2 px-3 py-1.5">
              {editingId === sub.id ? (
                <>
                  <Input
                    value={editName}
                    onChange={(e) => setEditName(e.target.value)}
                    className="h-7 text-xs flex-1"
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') handleUpdate(sub.id);
                      if (e.key === 'Escape') setEditingId(null);
                    }}
                    autoFocus
                  />
                  <Button size="sm" onClick={() => handleUpdate(sub.id)}>Save</Button>
                  <Button size="sm" variant="ghost" onClick={() => setEditingId(null)}>Cancel</Button>
                </>
              ) : (
                <>
                  <span className="flex-1 text-xs">{sub.name}</span>
                  {sub.isPremium === 1 && (
                    <Badge variant="secondary" className="text-[10px] px-1 py-0">Premium</Badge>
                  )}
                  <Button
                    size="icon"
                    variant="ghost"
                    className="h-6 w-6"
                    title={sub.status === 1 ? 'Active (click to deactivate)' : 'Inactive (click to activate)'}
                    onClick={() => handleToggleStatus(sub)}
                  >
                    {sub.status === 1 ? (
                      <Eye className="h-3 w-3 text-green-600" />
                    ) : (
                      <EyeOff className="h-3 w-3 text-muted-foreground" />
                    )}
                  </Button>
                  <Button
                    size="icon"
                    variant="ghost"
                    className="h-6 w-6"
                    title="Toggle premium"
                    onClick={() => handleTogglePremium(sub)}
                  >
                    <Star className={`h-3 w-3 ${sub.isPremium === 1 ? 'fill-yellow-400 text-yellow-400' : 'text-muted-foreground'}`} />
                  </Button>
                  <Button
                    size="icon"
                    variant="ghost"
                    className="h-6 w-6"
                    onClick={() => { setEditingId(sub.id); setEditName(sub.name); }}
                  >
                    <Pencil className="h-3 w-3" />
                  </Button>
                  <Button
                    size="icon"
                    variant="ghost"
                    className="h-6 w-6"
                    onClick={() => setDeleteTarget(sub)}
                  >
                    <Trash2 className="h-3 w-3 text-destructive" />
                  </Button>
                </>
              )}
            </li>
          ))}
        </ul>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        onOpenChange={(open) => !open && setDeleteTarget(null)}
        title="Delete Subcategory"
        description={`Delete "${deleteTarget?.name}"?`}
        confirmWord="DELETE"
        onConfirm={handleDelete}
        isPending={false}
        variant="destructive"
        confirmLabel="Delete"
      />
    </div>
  );
}

// ---------------------------------------------------------------------------
// Sortable row
// ---------------------------------------------------------------------------
interface SortableCategoryRowProps {
  cat: Category;
  isEditing: boolean;
  editName: string;
  onEditNameChange: (v: string) => void;
  onEditStart: () => void;
  onEditSave: () => void;
  onEditCancel: () => void;
  onDelete: () => void;
  onTogglePremium: () => void;
}

function SortableCategoryRow({
  cat,
  isEditing,
  editName,
  onEditNameChange,
  onEditStart,
  onEditSave,
  onEditCancel,
  onDelete,
  onTogglePremium,
}: SortableCategoryRowProps) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } =
    useSortable({ id: cat.id });
  const style: React.CSSProperties = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
    zIndex: isDragging ? 10 : undefined,
  };

  const [expanded, setExpanded] = React.useState(false);

  return (
    <li ref={setNodeRef} style={style} className="border-b last:border-b-0">
      <div className="flex items-center gap-2 py-2 px-1">
        <button
          {...attributes}
          {...listeners}
          className="cursor-grab active:cursor-grabbing text-muted-foreground hover:text-foreground"
          aria-label="Drag to reorder"
          type="button"
        >
          <GripVertical className="h-4 w-4" />
        </button>

        {isEditing ? (
          <>
            <Input
              value={editName}
              onChange={(e) => onEditNameChange(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') onEditSave();
                if (e.key === 'Escape') onEditCancel();
              }}
              className="h-8 flex-1"
              autoFocus
            />
            <Button size="sm" onClick={onEditSave}>Save</Button>
            <Button size="sm" variant="ghost" onClick={onEditCancel}>Cancel</Button>
          </>
        ) : (
          <>
            <button
              type="button"
              className="flex-1 text-sm text-left font-medium hover:underline"
              onClick={() => setExpanded((v) => !v)}
            >
              {cat.name}
            </button>
            {cat.isPremium === 1 && (
              <Badge variant="secondary" className="text-xs">Premium</Badge>
            )}
            <Button
              size="icon"
              variant="ghost"
              title="Toggle premium"
              onClick={onTogglePremium}
            >
              <Star className={`h-4 w-4 ${cat.isPremium === 1 ? 'fill-yellow-400 text-yellow-400' : 'text-muted-foreground'}`} />
            </Button>
            <Button size="icon" variant="ghost" onClick={onEditStart}>
              <Pencil className="h-4 w-4" />
            </Button>
            <Button size="icon" variant="ghost" onClick={onDelete}>
              <Trash2 className="h-4 w-4 text-destructive" />
            </Button>
            <button
              type="button"
              className="text-muted-foreground"
              onClick={() => setExpanded((v) => !v)}
              aria-label="Toggle subcategories"
            >
              {expanded ? (
                <ChevronDown className="h-4 w-4" />
              ) : (
                <ChevronRight className="h-4 w-4" />
              )}
            </button>
          </>
        )}
      </div>
      {expanded && <SubcategoryPanel categoryId={cat.id} />}
    </li>
  );
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
interface CategoriesManagerProps {
  initialCategories: Category[];
}

export function CategoriesManager({ initialCategories }: CategoriesManagerProps) {
  const api = useApiClient();
  const router = useRouter();

  const [categories, setCategories] = React.useState<Category[]>(initialCategories);
  const [newName, setNewName] = React.useState('');
  const [isCreating, setIsCreating] = React.useState(false);
  const [editingId, setEditingId] = React.useState<number | null>(null);
  const [editName, setEditName] = React.useState('');
  const [deleteTarget, setDeleteTarget] = React.useState<Category | null>(null);

  const sensors = useSensors(useSensor(PointerSensor));

  async function handleCreate() {
    const name = newName.trim();
    if (!name) return;
    setIsCreating(true);
    try {
      const created = await api
        .post(`/v2/admin/categories`, { name })
        .then((r) => r.data as Category);
      setCategories((prev) => [...prev, created]);
      setNewName('');
      toast.success('Category created');
    } catch {
      toast.error('Failed to create category');
    } finally {
      setIsCreating(false);
    }
  }

  async function handleUpdate(id: number) {
    const name = editName.trim();
    if (!name) return;
    try {
      await api.patch(`/v2/admin/categories/${id}`, { name });
      setCategories((prev) => prev.map((c) => (c.id === id ? { ...c, name } : c)));
      setEditingId(null);
      toast.success('Category updated');
    } catch {
      toast.error('Failed to update category');
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    try {
      await api.delete(`/v2/admin/categories/${deleteTarget.id}`);
      setCategories((prev) => prev.filter((c) => c.id !== deleteTarget.id));
      toast.success('Category deleted');
    } catch {
      toast.error('Failed to delete category');
    } finally {
      setDeleteTarget(null);
    }
  }

  async function handleTogglePremium(cat: Category) {
    const newVal = cat.isPremium === 1 ? 0 : 1;
    try {
      await api.patch(`/v2/admin/categories/${cat.id}`, { isPremium: newVal });
      setCategories((prev) => prev.map((c) => (c.id === cat.id ? { ...c, isPremium: newVal } : c)));
    } catch {
      toast.error('Failed to update premium');
    }
  }

  async function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    const oldIndex = categories.findIndex((c) => c.id === active.id);
    const newIndex = categories.findIndex((c) => c.id === over.id);
    const reordered = arrayMove(categories, oldIndex, newIndex);
    setCategories(reordered);
    try {
      await api.patch(`/v2/admin/categories/reorder`, {
        ids: reordered.map((c) => c.id),
      });
      router.refresh();
    } catch {
      toast.error('Failed to save order');
      setCategories(categories);
    }
  }

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Add Category</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex gap-2">
            <Input
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              placeholder="Category name"
              onKeyDown={(e) => e.key === 'Enter' && handleCreate()}
            />
            <Button onClick={handleCreate} disabled={isCreating || !newName.trim()}>
              <Plus className="h-4 w-4 mr-1" />
              Add
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>All Categories ({categories.length})</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          {categories.length === 0 ? (
            <p className="text-sm text-muted-foreground p-4">No categories yet.</p>
          ) : (
            <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
              <SortableContext items={categories.map((c) => c.id)} strategy={verticalListSortingStrategy}>
                <ul>
                  {categories.map((cat) => (
                    <SortableCategoryRow
                      key={cat.id}
                      cat={cat}
                      isEditing={editingId === cat.id}
                      editName={editName}
                      onEditNameChange={setEditName}
                      onEditStart={() => { setEditingId(cat.id); setEditName(cat.name); }}
                      onEditSave={() => handleUpdate(cat.id)}
                      onEditCancel={() => setEditingId(null)}
                      onDelete={() => setDeleteTarget(cat)}
                      onTogglePremium={() => handleTogglePremium(cat)}
                    />
                  ))}
                </ul>
              </SortableContext>
            </DndContext>
          )}
        </CardContent>
      </Card>

      <ConfirmDialog
        open={!!deleteTarget}
        onOpenChange={(open) => !open && setDeleteTarget(null)}
        title="Delete Category"
        description={`Delete "${deleteTarget?.name}"? Questions in this category may be affected.`}
        confirmWord="DELETE"
        onConfirm={handleDelete}
        isPending={false}
        variant="destructive"
        confirmLabel="Delete"
      />
    </>
  );
}
