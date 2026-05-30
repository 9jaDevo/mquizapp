'use client';

import { useState, useEffect, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { toast } from 'sonner';
import apiClient from '@/lib/api-client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';

interface DayQuestion {
  linkId: number;
  questionId: number;
  order: number;
  text: string;
  answer: string | null;
  categoryId: number | null;
  level: number | null;
}

interface QuestionBankResult {
  id: number;
  question: string;
  answer: string;
  category: number;
  level: number;
}

export default function LeagueDayQuestionsPage() {
  const { id: leagueId, quizDayId } = useParams<{ id: string; quizDayId: string }>();
  const router = useRouter();

  const [questions, setQuestions] = useState<DayQuestion[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteTarget, setDeleteTarget] = useState<number | null>(null);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [searchResults, setSearchResults] = useState<QuestionBankResult[]>([]);
  const [searching, setSearching] = useState(false);
  const [adding, setAdding] = useState(false);
  const [quizDayInfo, setQuizDayInfo] = useState<{ quizDay: number } | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiClient.get<{ questions: DayQuestion[]; total: number; quizDay: number }>(
        `/v2/admin/leagues/${leagueId}/quiz-days/${quizDayId}/questions`,
      );
      setQuestions(res.data.questions ?? []);
      setQuizDayInfo({ quizDay: res.data.quizDay });
    } catch (e: unknown) {
      toast.error(e instanceof Error ? e.message : 'Failed to load questions');
    } finally {
      setLoading(false);
    }
  }, [leagueId, quizDayId]);

  useEffect(() => { void load(); }, [load]);

  const handleSearch = async () => {
    if (!searchText.trim()) return;
    setSearching(true);
    try {
      const res = await apiClient.get<{ questions: QuestionBankResult[] }>(
        `/v2/admin/questions?search=${encodeURIComponent(searchText.trim())}&limit=20`,
      );
      setSearchResults(res.data.questions ?? (res.data as unknown as QuestionBankResult[]) ?? []);
    } catch (e: unknown) {
      toast.error(e instanceof Error ? e.message : 'Search failed');
    } finally {
      setSearching(false);
    }
  };

  const handleAdd = async (questionId: number) => {
    setAdding(true);
    try {
      await apiClient.post(`/v2/admin/leagues/${leagueId}/quiz-days/${quizDayId}/questions`, {
        questionIds: [questionId],
      });
      toast.success('Question added');
      await load();
    } catch (e: unknown) {
      toast.error(e instanceof Error ? e.message : 'Failed to add question');
    } finally {
      setAdding(false);
    }
  };

  const handleDelete = async () => {
    if (deleteTarget === null) return;
    try {
      await apiClient.delete(`/v2/admin/leagues/${leagueId}/quiz-days/${quizDayId}/questions/${deleteTarget}`);
      toast.success('Question removed');
      setDeleteTarget(null);
      await load();
    } catch (e: unknown) {
      toast.error(e instanceof Error ? e.message : 'Failed to remove question');
    }
  };

  const alreadyAdded = new Set(questions.map((q) => q.questionId));

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Day {quizDayInfo?.quizDay ?? quizDayId} Questions</h1>
          <p className="text-muted-foreground">
            League #{leagueId} — {questions.length} question(s) assigned
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => router.back()}>Back</Button>
          <Button onClick={() => { setSearchText(''); setSearchResults([]); setShowAddDialog(true); }}>
            + Add from Bank
          </Button>
        </div>
      </div>

      {loading ? (
        <p className="text-muted-foreground">Loading…</p>
      ) : questions.length === 0 ? (
        <div className="rounded-md border p-8 text-center text-muted-foreground">
          No questions assigned yet. Click &quot;Add from Bank&quot; to add questions from the question bank.
        </div>
      ) : (
        <div className="rounded-md border overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12">Order</TableHead>
                <TableHead>Question</TableHead>
                <TableHead className="w-20">Answer</TableHead>
                <TableHead className="w-20">Level</TableHead>
                <TableHead className="w-24">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {questions.map((q) => (
                <TableRow key={q.linkId}>
                  <TableCell className="text-muted-foreground font-mono">{q.order}</TableCell>
                  <TableCell className="max-w-md">
                    <p className="line-clamp-2 text-sm">{q.text}</p>
                    <p className="text-xs text-muted-foreground">ID: {q.questionId}</p>
                  </TableCell>
                  <TableCell className="uppercase font-mono font-bold text-green-600">{q.answer}</TableCell>
                  <TableCell className="text-muted-foreground">{q.level ?? '—'}</TableCell>
                  <TableCell>
                    <Button size="sm" variant="destructive" onClick={() => setDeleteTarget(q.linkId)}>
                      Remove
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}

      {/* Add from Bank Dialog */}
      <Dialog open={showAddDialog} onOpenChange={setShowAddDialog}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Add Questions from Question Bank</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="flex gap-2">
              <Input
                placeholder="Search question text…"
                value={searchText}
                onChange={(e) => setSearchText(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && void handleSearch()}
              />
              <Button onClick={handleSearch} disabled={searching}>
                {searching ? 'Searching…' : 'Search'}
              </Button>
            </div>
            {searchResults.length > 0 && (
              <div className="rounded-md border divide-y max-h-80 overflow-y-auto">
                {searchResults.map((q) => (
                  <div key={q.id} className="flex items-start justify-between gap-3 p-3">
                    <div className="flex-1 min-w-0">
                      <p className="text-sm line-clamp-2">{q.question}</p>
                      <p className="text-xs text-muted-foreground mt-1">
                        ID: {q.id} · Answer: {q.answer} · Level: {q.level}
                      </p>
                    </div>
                    <Button
                      size="sm"
                      disabled={adding || alreadyAdded.has(q.id)}
                      onClick={() => void handleAdd(q.id)}
                    >
                      {alreadyAdded.has(q.id) ? 'Added' : 'Add'}
                    </Button>
                  </div>
                ))}
              </div>
            )}
            {searchResults.length === 0 && searchText && !searching && (
              <p className="text-sm text-muted-foreground text-center py-4">No questions found. Try a different search term.</p>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAddDialog(false)}>Close</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Remove Confirmation */}
      <AlertDialog open={deleteTarget !== null} onOpenChange={(o) => !o && setDeleteTarget(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Remove question?</AlertDialogTitle>
            <AlertDialogDescription>
              This will unlink the question from this daily quiz. The question itself will not be deleted.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete}>Remove</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
