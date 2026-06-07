'use client';

import { useState, useEffect, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { toast } from 'sonner';
import apiClient from '@/lib/api-client';
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

interface ContestQuestion {
  id: number;
  text: string;
  type: number;
  image: string | null;
  options: { a: string; b: string; c: string; d: string; e?: string };
  answer: string;
  note: string | null;
  languageId: number;
}

const BLANK_FORM = {
  question: '',
  optiona: '',
  optionb: '',
  optionc: '',
  optiond: '',
  optione: '',
  answer: 'a',
  image: '',
  note: '',
};

export default function ContestQuestionsPage() {
  const { id: contestId } = useParams<{ id: string }>();
  const router = useRouter();

  const [questions, setQuestions] = useState<ContestQuestion[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [editTarget, setEditTarget] = useState<ContestQuestion | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<number | null>(null);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({ ...BLANK_FORM });

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiClient.get<{ questions: ContestQuestion[]; total: number }>(
        `/v2/admin/contests/${contestId}/questions`,
      );
      setQuestions(res.data.questions ?? []);
    } catch (e: unknown) {
      toast.error(e instanceof Error ? e.message : 'Failed to load questions');
    } finally {
      setLoading(false);
    }
  }, [contestId]);

  useEffect(() => { void load(); }, [load]);

  const openAdd = () => { setForm({ ...BLANK_FORM }); setEditTarget(null); setShowAddDialog(true); };
  const openEdit = (q: ContestQuestion) => {
    setForm({
      question: q.text,
      optiona: q.options.a,
      optionb: q.options.b,
      optionc: q.options.c,
      optiond: q.options.d,
      optione: q.options.e ?? '',
      answer: q.answer,
      image: q.image ?? '',
      note: q.note ?? '',
    });
    setEditTarget(q);
    setShowAddDialog(true);
  };

  const handleSave = async () => {
    if (!form.question.trim() || !form.optiona.trim() || !form.optionb.trim() || !form.optionc.trim() || !form.optiond.trim()) {
      toast.error('Question text and options A-D are required');
      return;
    }
    setSaving(true);
    try {
      const payload = {
        question: form.question.trim(),
        optiona: form.optiona.trim(),
        optionb: form.optionb.trim(),
        optionc: form.optionc.trim(),
        optiond: form.optiond.trim(),
        optione: form.optione.trim() || undefined,
        answer: form.answer,
        image: form.image.trim() || undefined,
        note: form.note.trim() || undefined,
      };
      if (editTarget) {
        await apiClient.put(`/v2/admin/contests/${contestId}/questions/${editTarget.id}`, payload);
        toast.success('Question updated');
      } else {
        await apiClient.post(`/v2/admin/contests/${contestId}/questions`, payload);
        toast.success('Question added');
      }
      setShowAddDialog(false);
      await load();
    } catch (e: unknown) {
      toast.error(e instanceof Error ? e.message : 'Failed to save question');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (deleteTarget === null) return;
    try {
      await apiClient.delete(`/v2/admin/contests/${contestId}/questions/${deleteTarget}`);
      toast.success('Question removed');
      setDeleteTarget(null);
      await load();
    } catch (e: unknown) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete question');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Contest Questions</h1>
          <p className="text-muted-foreground">Contest #{contestId} — {questions.length} question(s)</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => router.back()}>Back</Button>
          <Button onClick={openAdd}>+ Add Question</Button>
        </div>
      </div>

      {loading ? (
        <p className="text-muted-foreground">Loading…</p>
      ) : questions.length === 0 ? (
        <div className="rounded-md border p-8 text-center text-muted-foreground">
          No questions yet. Click &quot;Add Question&quot; to create the first one.
        </div>
      ) : (
        <div className="rounded-md border overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12">#</TableHead>
                <TableHead>Question</TableHead>
                <TableHead className="w-24">Answer</TableHead>
                <TableHead className="w-28">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {questions.map((q, i) => (
                <TableRow key={q.id}>
                  <TableCell className="text-muted-foreground">{i + 1}</TableCell>
                  <TableCell className="max-w-md">
                    <p className="line-clamp-2 text-sm">{q.text}</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      A: {q.options.a} · B: {q.options.b} · C: {q.options.c} · D: {q.options.d}
                      {q.options.e ? ` · E: ${q.options.e}` : ''}
                    </p>
                  </TableCell>
                  <TableCell className="uppercase font-mono font-bold text-green-600">{q.answer}</TableCell>
                  <TableCell>
                    <div className="flex gap-1">
                      <Button size="sm" variant="outline" onClick={() => openEdit(q)}>Edit</Button>
                      <Button size="sm" variant="destructive" onClick={() => setDeleteTarget(q.id)}>Del</Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}

      {/* Add / Edit Dialog */}
      <Dialog open={showAddDialog} onOpenChange={setShowAddDialog}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editTarget ? 'Edit Question' : 'Add Question'}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div>
              <Label>Question Text *</Label>
              <Textarea
                value={form.question}
                onChange={(e) => setForm((f) => ({ ...f, question: e.target.value }))}
                rows={3}
                placeholder="Enter the question…"
              />
            </div>
            {(['a', 'b', 'c', 'd', 'e'] as const).map((opt) => (
              <div key={opt}>
                <Label>Option {opt.toUpperCase()} {opt === 'e' ? '(optional)' : '*'}</Label>
                <Input
                  value={form[`option${opt}` as keyof typeof form]}
                  onChange={(e) => setForm((f) => ({ ...f, [`option${opt}`]: e.target.value }))}
                  placeholder={`Option ${opt.toUpperCase()}`}
                />
              </div>
            ))}
            <div>
              <Label>Correct Answer *</Label>
              <Select value={form.answer} onValueChange={(v) => setForm((f) => ({ ...f, answer: v ?? f.answer }))}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {['a', 'b', 'c', 'd', 'e'].map((o) => (
                    <SelectItem key={o} value={o}>{o.toUpperCase()}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label>Image URL (optional)</Label>
              <Input
                value={form.image}
                onChange={(e) => setForm((f) => ({ ...f, image: e.target.value }))}
                placeholder="https://…"
              />
            </div>
            <div>
              <Label>Explanation / Note (optional)</Label>
              <Textarea
                value={form.note}
                onChange={(e) => setForm((f) => ({ ...f, note: e.target.value }))}
                rows={2}
                placeholder="Answer explanation…"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAddDialog(false)}>Cancel</Button>
            <Button onClick={handleSave} disabled={saving}>{saving ? 'Saving…' : 'Save'}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation */}
      <AlertDialog open={deleteTarget !== null} onOpenChange={(o) => !o && setDeleteTarget(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Remove question?</AlertDialogTitle>
            <AlertDialogDescription>
              This will permanently delete this contest question. This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete}>Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
