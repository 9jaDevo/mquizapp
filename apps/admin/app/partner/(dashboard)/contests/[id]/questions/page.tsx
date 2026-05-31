'use client';

import { useEffect, useState } from 'react';
import { partnerApi } from '@/lib/partner-api-client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { toast } from 'sonner';
import { Trash2 } from 'lucide-react';

interface Question {
  id: number; questionOrder: number; questionText: string; optionA: string; optionB: string;
  optionC: string; optionD: string; optionE?: string; answer: string; explanation?: string;
}
interface Params { params: Promise<{ id: string }> }

const EMPTY_FORM = { questionText: '', optionA: '', optionB: '', optionC: '', optionD: '', optionE: '', answer: 'a', explanation: '' };

export default function QuestionsPage({ params }: Params) {
  const [contestId, setContestId] = useState(0);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [form, setForm] = useState(EMPTY_FORM);
  const [adding, setAdding] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    void params.then(({ id }) => {
      const cid = parseInt(id);
      setContestId(cid);
      loadQuestions(cid);
    });
  }, [params]);

  function loadQuestions(cid: number) {
    setLoading(true);
    void partnerApi.listQuestions(cid).then((q) => {
      setQuestions(q as Question[]);
    }).finally(() => setLoading(false));
  }

  async function handleAdd(e: React.FormEvent) {
    e.preventDefault();
    setAdding(true);
    try {
      await partnerApi.addQuestion(contestId, { ...form, optionE: form.optionE || undefined });
      toast.success('Question added');
      setForm(EMPTY_FORM);
      loadQuestions(contestId);
    } catch (err) { toast.error((err as Error).message); }
    finally { setAdding(false); }
  }

  async function handleDelete(qid: number) {
    if (!confirm('Delete this question?')) return;
    try {
      await partnerApi.deleteQuestion(contestId, qid);
      toast.success('Deleted');
      loadQuestions(contestId);
    } catch (err) { toast.error((err as Error).message); }
  }

  function set(field: string, value: string) { setForm((p) => ({ ...p, [field]: value })); }

  if (loading) return <div className="text-muted-foreground">Loading…</div>;

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold">Questions ({questions.length})</h1>

      {/* Existing questions */}
      <div className="space-y-3">
        {questions.map((q, i) => (
          <div key={q.id} className="rounded-lg border p-4">
            <div className="flex items-start justify-between gap-2">
              <div className="flex-1">
                <p className="font-medium text-sm">{i + 1}. {q.questionText}</p>
                <div className="mt-2 grid grid-cols-2 gap-1 text-xs text-muted-foreground">
                  <span>A: {q.optionA}</span>
                  <span>B: {q.optionB}</span>
                  <span>C: {q.optionC}</span>
                  <span>D: {q.optionD}</span>
                  {q.optionE && <span>E: {q.optionE}</span>}
                </div>
                <p className="mt-1 text-xs font-medium text-green-600">Answer: {q.answer.toUpperCase()}</p>
              </div>
              <Button size="icon" variant="ghost" className="text-destructive" onClick={() => void handleDelete(q.id)}>
                <Trash2 className="size-4" />
              </Button>
            </div>
          </div>
        ))}
      </div>

      {/* Add question form */}
      <div className="rounded-lg border p-5">
        <h2 className="mb-4 text-lg font-semibold">Add Question</h2>
        <form onSubmit={(e) => { void handleAdd(e); }} className="space-y-4">
          <div className="space-y-2">
            <Label>Question Text *</Label>
            <Textarea value={form.questionText} onChange={(e) => set('questionText', e.target.value)} required rows={2} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            {['optionA', 'optionB', 'optionC', 'optionD'].map((opt) => (
              <div key={opt} className="space-y-1">
                <Label className="text-xs">{opt.replace('option', 'Option ')} *</Label>
                <Input value={form[opt as keyof typeof form]} onChange={(e) => set(opt, e.target.value)} required />
              </div>
            ))}
            <div className="space-y-1">
              <Label className="text-xs">Option E (optional)</Label>
              <Input value={form.optionE} onChange={(e) => set('optionE', e.target.value)} />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-2">
              <Label>Correct Answer *</Label>
              <Select value={form.answer} onValueChange={(v) => set('answer', v)}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  {['a', 'b', 'c', 'd', 'e'].map((l) => <SelectItem key={l} value={l}>Option {l.toUpperCase()}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Explanation (optional)</Label>
              <Input value={form.explanation} onChange={(e) => set('explanation', e.target.value)} />
            </div>
          </div>
          <Button type="submit" disabled={adding}>{adding ? 'Adding…' : 'Add Question'}</Button>
        </form>
      </div>
    </div>
  );
}
