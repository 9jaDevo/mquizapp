'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { useApiClient } from '@/hooks/use-api-client';
import type { Category, Question } from '@/types/api';

const schema = z.object({
  topic: z.string().min(3, 'Topic must be at least 3 characters'),
  count: z.number().int().min(1).max(20),
  difficultyLevel: z.enum(['easy', 'medium', 'hard']),
  categoryId: z.number({ error: 'Category is required' }),
});

type FormData = z.infer<typeof schema>;

interface AiQuestionsPanelProps {
  categories: Category[];
}

export function AiQuestionsPanel({ categories }: AiQuestionsPanelProps) {
  const api = useApiClient();
  const [generatedQuestions, setGeneratedQuestions] = React.useState<Question[]>([]);
  const [isApproving, setIsApproving] = React.useState(false);

  const {
    register,
    handleSubmit,
    setValue,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { count: 5, difficultyLevel: 'medium' },
  });

  async function onGenerate(data: FormData) {
    setGeneratedQuestions([]);
    try {
      const questions = await api
        .post<Question[]>('/v2/admin/questions/generate', data)
        .then((r) => r.data as Question[]);
      setGeneratedQuestions(questions);
      toast.success(`Generated ${questions.length} questions`);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Generation failed');
    }
  }

  async function handleApproveAll() {
    if (generatedQuestions.length === 0) return;
    setIsApproving(true);
    try {
      await api.post('/v2/admin/questions/approve-batch', {
        questionIds: generatedQuestions.map((q) => q.id),
      });
      toast.success('All questions approved and published');
      setGeneratedQuestions([]);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Approval failed');
    } finally {
      setIsApproving(false);
    }
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Generate Questions</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onGenerate)} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="topic">Topic</Label>
              <Input
                id="topic"
                {...register('topic')}
                placeholder="e.g. African History, Mathematics, Science"
              />
              {errors.topic && (
                <p className="text-sm text-destructive">{errors.topic.message}</p>
              )}
            </div>

            <div className="grid gap-4 sm:grid-cols-3">
              <div className="space-y-2">
                <Label htmlFor="count">Count (1–20)</Label>
                <Input
                  id="count"
                  type="number"
                  min={1}
                  max={20}
                  {...register('count', { valueAsNumber: true })}
                />
              </div>
              <div className="space-y-2">
                <Label>Difficulty</Label>
                <Select
                  onValueChange={(v) =>
                    setValue('difficultyLevel', v as 'easy' | 'medium' | 'hard')
                  }
                  defaultValue="medium"
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="easy">Easy</SelectItem>
                    <SelectItem value="medium">Medium</SelectItem>
                    <SelectItem value="hard">Hard</SelectItem>
                  </SelectContent>
                </Select>
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
              </div>
            </div>

            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Generating...' : 'Generate'}
            </Button>
          </form>
        </CardContent>
      </Card>

      {generatedQuestions.length > 0 && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Generated Questions ({generatedQuestions.length})</CardTitle>
            <Button onClick={handleApproveAll} disabled={isApproving} size="sm">
              {isApproving ? 'Approving...' : 'Approve All'}
            </Button>
          </CardHeader>
          <CardContent>
            <ul className="space-y-4">
              {generatedQuestions.map((q, i) => (
                <li key={q.id ?? i} className="rounded-md border p-4 text-sm space-y-2">
                  <p className="font-medium">{q.questionText}</p>
                  <ul className="space-y-1">
                    {q.options.map((opt, j) => (
                      <li
                        key={j}
                        className={
                          opt === q.correctAnswer
                            ? 'text-green-600 font-medium'
                            : 'text-muted-foreground'
                        }
                      >
                        {String.fromCharCode(65 + j)}. {opt}
                      </li>
                    ))}
                  </ul>
                  <Badge variant="outline">{q.difficultyLevel}</Badge>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
