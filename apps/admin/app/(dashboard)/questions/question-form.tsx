'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { useForm, useWatch } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useApiClient } from '@/hooks/use-api-client';
import type { Category, Question } from '@/types/api';

const schema = z.object({
  category: z.number({ error: 'Category is required' }),
  subcategory: z.number().int().min(0),
  languageId: z.number().int().min(0),
  question: z.string().min(5, 'Question must be at least 5 characters').max(4000),
  questionType: z.number().int().min(0).max(10),
  optiona: z.string().min(1, 'Required').max(1024),
  optionb: z.string().min(1, 'Required').max(1024),
  optionc: z.string().min(1, 'Required').max(1024),
  optiond: z.string().min(1, 'Required').max(1024),
  optione: z.string().max(1024).optional(),
  answer: z.string().min(1, 'Correct answer key required').max(8),
  level: z.number().int().min(1).max(10),
  image: z.string().max(512).optional(),
  note: z.string().max(2048).optional(),
});

type FormData = z.infer<typeof schema>;

interface QuestionFormProps {
  categories: Category[];
  question?: Question;
}

export function QuestionForm({ categories, question }: QuestionFormProps) {
  const router = useRouter();
  const api = useApiClient();
  const isEdit = !!question;

  const {
    register,
    handleSubmit,
    setValue,
    control,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: question
      ? {
          category: question.category,
          subcategory: question.subcategory,
          languageId: question.languageId,
          question: question.question,
          questionType: question.questionType,
          optiona: question.optiona,
          optionb: question.optionb,
          optionc: question.optionc,
          optiond: question.optiond,
          optione: question.optione ?? '',
          answer: question.answer,
          level: question.level,
          image: question.image,
          note: question.note,
        }
      : {
          subcategory: 0,
          languageId: 0,
          questionType: 0,
          level: 1,
          answer: 'a',
        },
  });

  async function onSubmit(data: FormData) {
    try {
      const payload = { ...data };
      if (!payload.optione) delete payload.optione;
      if (!payload.image) delete payload.image;
      if (!payload.note) delete payload.note;
      if (isEdit) {
        await api.put(`/v2/admin/questions/${question!.id}`, payload);
        toast.success('Question updated');
      } else {
        await api.post('/v2/admin/questions', payload);
        toast.success('Question created');
      }
      router.push('/questions');
      router.refresh();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to save question');
    }
  }

  return (
    <Card>
      <CardContent className="pt-6">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="question">Question</Label>
            <Textarea id="question" rows={3} {...register('question')} placeholder="Enter the question" />
            {errors.question && (
              <p className="text-sm text-destructive">{errors.question.message}</p>
            )}
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="optiona">Option A</Label>
              <Input id="optiona" {...register('optiona')} />
              {errors.optiona && (
                <p className="text-sm text-destructive">{errors.optiona.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="optionb">Option B</Label>
              <Input id="optionb" {...register('optionb')} />
              {errors.optionb && (
                <p className="text-sm text-destructive">{errors.optionb.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="optionc">Option C</Label>
              <Input id="optionc" {...register('optionc')} />
              {errors.optionc && (
                <p className="text-sm text-destructive">{errors.optionc.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="optiond">Option D</Label>
              <Input id="optiond" {...register('optiond')} />
              {errors.optiond && (
                <p className="text-sm text-destructive">{errors.optiond.message}</p>
              )}
            </div>
            <div className="space-y-2 sm:col-span-2">
              <Label htmlFor="optione">Option E (optional)</Label>
              <Input id="optione" {...register('optione')} />
            </div>
          </div>

          <div className="grid gap-4 sm:grid-cols-3">
            <div className="space-y-2">
              <Label htmlFor="answer">Correct Key</Label>
              <Select
                onValueChange={(v) => v && setValue('answer', v)}
                defaultValue={question?.answer ?? 'a'}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="a">A</SelectItem>
                  <SelectItem value="b">B</SelectItem>
                  <SelectItem value="c">C</SelectItem>
                  <SelectItem value="d">D</SelectItem>
                  <SelectItem value="e">E</SelectItem>
                </SelectContent>
              </Select>
              {errors.answer && (
                <p className="text-sm text-destructive">{errors.answer.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="level">Difficulty (1–10)</Label>
              <Input
                id="level"
                type="number"
                min={1}
                max={10}
                {...register('level', { valueAsNumber: true })}
              />
            </div>
            <div className="space-y-2">
              <Label>Category</Label>
              <Select
                onValueChange={(v: string | null) =>
                  v && setValue('category', parseInt(v, 10))
                }
                defaultValue={question ? String(question.category) : undefined}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select category" />
                </SelectTrigger>
                <SelectContent>
                  {categories.map((cat) => (
                    <SelectItem key={cat.id} value={String(cat.id)}>
                      {cat.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              {errors.category && (
                <p className="text-sm text-destructive">{errors.category.message}</p>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="note">Explanation / Note (optional)</Label>
            <Textarea id="note" rows={2} {...register('note')} />
          </div>

          <div className="space-y-2">
            <Label htmlFor="image">Image URL (optional)</Label>
            <Input id="image" {...register('image')} placeholder="https://..." />
            <ImagePreview control={control} />
          </div>

          <div className="flex gap-3">
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Saving…' : isEdit ? 'Update Question' : 'Create Question'}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => router.back()}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}

// ── Inline Image Preview ──────────────────────────────────────────────────────

import { Control } from 'react-hook-form';

function ImagePreview({ control }: { control: Control<FormData> }) {
  const imageUrl = useWatch({ control, name: 'image' });
  if (!imageUrl || !imageUrl.startsWith('http')) return null;
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={imageUrl}
      alt="Question image preview"
      className="mt-2 max-h-40 rounded-md border object-contain"
      onError={(e) => {
        (e.target as HTMLImageElement).style.display = 'none';
      }}
    />
  );
}
