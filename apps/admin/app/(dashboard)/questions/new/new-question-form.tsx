'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useApiClient } from '@/hooks/use-api-client';
import type { Category } from '@/types/api';

const schema = z.object({
  questionText: z.string().min(5, 'Question must be at least 5 characters'),
  options: z.array(z.string().min(1, 'Option cannot be empty')).length(4),
  correctAnswer: z.string().min(1, 'Correct answer is required'),
  explanation: z.string().optional(),
  difficultyLevel: z.enum(['easy', 'medium', 'hard']),
  categoryId: z.number({ error: 'Category is required' }),
});

type FormData = z.infer<typeof schema>;

interface NewQuestionFormProps {
  categories: Category[];
}

export function NewQuestionForm({ categories }: NewQuestionFormProps) {
  const router = useRouter();
  const api = useApiClient();

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      options: ['', '', '', ''],
      difficultyLevel: 'medium',
    },
  });

  async function onSubmit(data: FormData) {
    try {
      await api.post('/v2/admin/questions', data);
      toast.success('Question created');
      router.push('/questions');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to create question');
    }
  }

  const options = watch('options');

  return (
    <Card>
      <CardContent className="pt-6">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="questionText">Question</Label>
            <Textarea
              id="questionText"
              {...register('questionText')}
              rows={3}
              placeholder="Enter the question text"
            />
            {errors.questionText && (
              <p className="text-sm text-destructive">{errors.questionText.message}</p>
            )}
          </div>

          <div className="space-y-3">
            <Label>Options (A–D)</Label>
            {[0, 1, 2, 3].map((i) => (
              <div key={i} className="flex gap-2">
                <span className="flex h-9 w-8 shrink-0 items-center justify-center rounded border bg-muted text-sm font-medium">
                  {String.fromCharCode(65 + i)}
                </span>
                <Input
                  {...register(`options.${i}`)}
                  placeholder={`Option ${String.fromCharCode(65 + i)}`}
                />
              </div>
            ))}
            {errors.options && (
              <p className="text-sm text-destructive">All options are required</p>
            )}
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="correctAnswer">Correct Answer</Label>
              <Input
                id="correctAnswer"
                {...register('correctAnswer')}
                placeholder="e.g. A or exact answer text"
              />
              {errors.correctAnswer && (
                <p className="text-sm text-destructive">{errors.correctAnswer.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label>Difficulty</Label>
              <Select
                onValueChange={(v) => setValue('difficultyLevel', v as 'easy' | 'medium' | 'hard')}
                defaultValue="medium"
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select difficulty" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="easy">Easy</SelectItem>
                  <SelectItem value="medium">Medium</SelectItem>
                  <SelectItem value="hard">Hard</SelectItem>
                </SelectContent>
              </Select>
              {errors.difficultyLevel && (
                <p className="text-sm text-destructive">{errors.difficultyLevel.message}</p>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label>Category</Label>
            <Select onValueChange={(v) => setValue('categoryId', parseInt(v, 10))}>
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
            {errors.categoryId && (
              <p className="text-sm text-destructive">{errors.categoryId.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="explanation">Explanation (optional)</Label>
            <Textarea
              id="explanation"
              {...register('explanation')}
              rows={2}
              placeholder="Explain why this is the correct answer"
            />
          </div>

          <div className="flex gap-3">
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Creating...' : 'Create Question'}
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
