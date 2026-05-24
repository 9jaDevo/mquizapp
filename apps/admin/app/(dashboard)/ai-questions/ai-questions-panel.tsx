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
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
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

interface PendingAiQuestion {
  id: string;
  question: string;
  options: string;
  correctAnswer: string;
  level: number;
  category: number;
  note?: string | null;
  dateTime?: string;
}

interface PendingResp {
  items: PendingAiQuestion[];
  pagination?: { page: number; limit: number; total: number; pages: number };
}

function parseOptions(raw: string): string[] {
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed)) return parsed.map(String);
    if (parsed && typeof parsed === 'object') return Object.values(parsed).map(String);
  } catch {
    // fallback below
  }
  return raw.split('|').map((s) => s.trim()).filter(Boolean);
}

export function AiQuestionsPanel({ categories }: AiQuestionsPanelProps) {
  const api = useApiClient();
  const [generatedQuestions, setGeneratedQuestions] = React.useState<Question[]>([]);
  const [isApproving, setIsApproving] = React.useState(false);

  const [pending, setPending] = React.useState<PendingAiQuestion[]>([]);
  const [pendingLoading, setPendingLoading] = React.useState(false);
  const [busyId, setBusyId] = React.useState<string | null>(null);

  const [rejectTarget, setRejectTarget] = React.useState<PendingAiQuestion | null>(null);
  const [rejectReason, setRejectReason] = React.useState('');

  const {
    register,
    handleSubmit,
    setValue,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { count: 5, difficultyLevel: 'medium' },
  });

  const loadPending = React.useCallback(async () => {
    setPendingLoading(true);
    try {
      const res = await api
        .get<PendingResp>('/v2/admin/ai-questions/pending?page=1&limit=50')
        .then((r) => r.data as PendingResp);
      setPending(res.items ?? []);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to load pending');
    } finally {
      setPendingLoading(false);
    }
  }, [api]);

  async function onGenerate(data: FormData) {
    setGeneratedQuestions([]);
    try {
      const questions = await api
        .post<Question[]>('/v2/admin/questions/generate', data)
        .then((r) => r.data as Question[]);
      setGeneratedQuestions(questions);
      toast.success(`Generated ${questions.length} questions`);
      loadPending();
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

  async function approveOne(q: PendingAiQuestion) {
    setBusyId(q.id);
    try {
      await api.post(`/v2/admin/ai-questions/${q.id}/approve`, {});
      setPending((prev) => prev.filter((x) => x.id !== q.id));
      toast.success('Question approved');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Approval failed');
    } finally {
      setBusyId(null);
    }
  }

  async function confirmReject() {
    if (!rejectTarget) return;
    setBusyId(rejectTarget.id);
    try {
      await api.post(`/v2/admin/ai-questions/${rejectTarget.id}/reject`, {
        reason: rejectReason || undefined,
      });
      setPending((prev) => prev.filter((x) => x.id !== rejectTarget.id));
      toast.success('Question rejected');
      setRejectTarget(null);
      setRejectReason('');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Reject failed');
    } finally {
      setBusyId(null);
    }
  }

  return (
    <Tabs defaultValue="generate" onValueChange={(v) => v === 'pending' && loadPending()}>
      <TabsList>
        <TabsTrigger value="generate">Generate</TabsTrigger>
        <TabsTrigger value="pending">Pending Queue</TabsTrigger>
      </TabsList>

      <TabsContent value="generate" className="space-y-6">
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
                      v && setValue('difficultyLevel', v as 'easy' | 'medium' | 'hard')
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
                  <Select onValueChange={(v: string | null) => v && setValue('categoryId', parseInt(v, 10))}>
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
                {generatedQuestions.map((q, i) => {
                  const opts = [q.optiona, q.optionb, q.optionc, q.optiond];
                  if (q.optione) opts.push(q.optione);
                  const correctIdx = q.answer
                    ? q.answer.toLowerCase().charCodeAt(0) - 97
                    : -1;
                  return (
                    <li key={q.id ?? i} className="rounded-md border p-4 text-sm space-y-2">
                      <p className="font-medium">{q.question}</p>
                      <ul className="space-y-1">
                        {opts.map((opt, j) => (
                          <li
                            key={j}
                            className={
                              j === correctIdx
                                ? 'text-green-600 font-medium'
                                : 'text-muted-foreground'
                            }
                          >
                            {String.fromCharCode(65 + j)}. {opt}
                          </li>
                        ))}
                      </ul>
                      <Badge variant="outline">Level {q.level}</Badge>
                    </li>
                  );
                })}
              </ul>
            </CardContent>
          </Card>
        )}
      </TabsContent>

      <TabsContent value="pending">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Pending AI Questions ({pending.length})</CardTitle>
            <Button size="sm" variant="outline" onClick={loadPending} disabled={pendingLoading}>
              {pendingLoading ? 'Refreshing…' : 'Refresh'}
            </Button>
          </CardHeader>
          <CardContent>
            {pendingLoading ? (
              <p className="text-sm text-muted-foreground py-8 text-center">Loading…</p>
            ) : pending.length === 0 ? (
              <p className="text-sm text-muted-foreground py-8 text-center">
                No pending AI questions.
              </p>
            ) : (
              <ul className="space-y-4">
                {pending.map((q) => {
                  const opts = parseOptions(q.options);
                  return (
                    <li key={q.id} className="rounded-md border p-4 text-sm space-y-3">
                      <p className="font-medium">{q.question}</p>
                      <ul className="space-y-1">
                        {opts.map((opt, j) => (
                          <li
                            key={j}
                            className={
                              opt === q.correctAnswer ||
                              String.fromCharCode(65 + j) === q.correctAnswer
                                ? 'text-green-600 font-medium'
                                : 'text-muted-foreground'
                            }
                          >
                            {String.fromCharCode(65 + j)}. {opt}
                          </li>
                        ))}
                      </ul>
                      <div className="flex items-center gap-2">
                        <Badge variant="outline">level {q.level}</Badge>
                        <Badge variant="secondary">cat {q.category}</Badge>
                        <div className="flex-1" />
                        <Button
                          size="sm"
                          onClick={() => approveOne(q)}
                          disabled={busyId === q.id}
                        >
                          Approve
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          onClick={() => setRejectTarget(q)}
                          disabled={busyId === q.id}
                        >
                          Reject
                        </Button>
                      </div>
                    </li>
                  );
                })}
              </ul>
            )}
          </CardContent>
        </Card>
      </TabsContent>

      <Dialog
        open={!!rejectTarget}
        onOpenChange={(open) => {
          if (!open) {
            setRejectTarget(null);
            setRejectReason('');
          }
        }}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject Question</DialogTitle>
          </DialogHeader>
          <div className="space-y-2">
            <Label htmlFor="reject-reason">Reason (optional)</Label>
            <Textarea
              id="reject-reason"
              rows={3}
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Why is this being rejected?"
            />
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setRejectTarget(null);
                setRejectReason('');
              }}
              disabled={!!busyId}
            >
              Cancel
            </Button>
            <Button variant="destructive" onClick={confirmReject} disabled={!!busyId}>
              {busyId ? 'Rejecting…' : 'Reject'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Tabs>
  );
}