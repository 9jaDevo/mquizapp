'use client';

import { useEffect, useState } from 'react';
import { partnerApi } from '@/lib/partner-api-client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { toast } from 'sonner';
import { useRouter } from 'next/navigation';

export default function NewContestPage() {
  const router = useRouter();
  const [form, setForm] = useState({
    title: '',
    description: '',
    visibility: 'public',
    maxParticipants: 50,
    timeLimitSeconds: 20,
    prizeDescription: '',
    startDate: '',
    endDate: '',
  });
  const [loading, setLoading] = useState(false);

  function set(field: string, value: string | number) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await partnerApi.createContest({
        ...form,
        startDate: form.startDate || undefined,
        endDate: form.endDate || undefined,
      }) as { id: number };
      toast.success('Contest created as draft');
      router.push(`/partner/contests/${res.id}`);
    } catch (e) {
      toast.error((e as Error).message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <h1 className="text-2xl font-bold">New Contest</h1>
      <form onSubmit={(e) => { void handleSubmit(e); }} className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="title">Contest Title *</Label>
          <Input id="title" value={form.title} onChange={(e) => set('title', e.target.value)} required maxLength={255} />
        </div>
        <div className="space-y-2">
          <Label htmlFor="description">Description</Label>
          <Textarea id="description" value={form.description} onChange={(e) => set('description', e.target.value)} rows={3} />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="visibility">Visibility</Label>
            <Select value={form.visibility} onValueChange={(v) => set('visibility', v)}>
              <SelectTrigger id="visibility"><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="public">Public (anyone can join)</SelectItem>
                <SelectItem value="private">Private (invite code)</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="maxParticipants">Max Participants</Label>
            <Input id="maxParticipants" type="number" min={1} value={form.maxParticipants}
              onChange={(e) => set('maxParticipants', parseInt(e.target.value))} />
          </div>
        </div>
        <div className="space-y-2">
          <Label htmlFor="timeLimitSeconds">Time per question (seconds)</Label>
          <Input id="timeLimitSeconds" type="number" min={5} max={300} value={form.timeLimitSeconds}
            onChange={(e) => set('timeLimitSeconds', parseInt(e.target.value))} />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="startDate">Start Date (optional)</Label>
            <Input id="startDate" type="datetime-local" value={form.startDate} onChange={(e) => set('startDate', e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="endDate">End Date (optional)</Label>
            <Input id="endDate" type="datetime-local" value={form.endDate} onChange={(e) => set('endDate', e.target.value)} />
          </div>
        </div>
        <div className="space-y-2">
          <Label htmlFor="prizeDescription">Prize Description (optional)</Label>
          <Textarea id="prizeDescription" value={form.prizeDescription} onChange={(e) => set('prizeDescription', e.target.value)} rows={2} />
        </div>
        <div className="flex gap-3 pt-2">
          <Button type="submit" disabled={loading}>{loading ? 'Creating…' : 'Create Contest'}</Button>
          <Button type="button" variant="outline" onClick={() => router.back()}>Cancel</Button>
        </div>
      </form>
    </div>
  );
}
