'use client';

import * as React from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { Plus, Trash2, Calendar } from 'lucide-react';
import { toast } from 'sonner';
import { Button, buttonVariants } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { useApiClient } from '@/hooks/use-api-client';

interface ScheduleDay {
  id: number;
  leagueId: number;
  quizDay: number;
  quizDate: string | null;
  questionCount: number;
  dateAssigned: string | null;
}

export default function LeagueQuizSchedulePage() {
  const { id: leagueId } = useParams<{ id: string }>();
  const api = useApiClient();

  const [schedule, setSchedule] = React.useState<ScheduleDay[]>([]);
  const [loading, setLoading] = React.useState(true);
  const [saving, setSaving] = React.useState(false);

  // New day form state
  const [newDay, setNewDay] = React.useState({ quizDay: '', quizDate: '', questionCount: '20' });

  React.useEffect(() => {
    if (!leagueId) return;
    setLoading(true);
    api
      .get<{ data: ScheduleDay[] } | ScheduleDay[]>(`/v2/admin/leagues/${leagueId}/quiz-schedule`)
      .then((res) => {
        const raw = res.data;
        const days = Array.isArray(raw) ? raw : (raw as { data: ScheduleDay[] }).data ?? [];
        setSchedule(days);
      })
      .catch((e) => toast.error(e instanceof Error ? e.message : 'Failed to load schedule'))
      .finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [leagueId]);

  async function handleAssign(e: React.FormEvent) {
    e.preventDefault();
    if (!leagueId || !newDay.quizDay || !newDay.quizDate) {
      toast.error('Day number and date are required');
      return;
    }
    setSaving(true);
    try {
      const res = await api.post<{ data: ScheduleDay } | ScheduleDay>(
        `/v2/admin/leagues/${leagueId}/assign-day`,
        {
          quizDay: parseInt(newDay.quizDay, 10),
          quizDate: newDay.quizDate,
          questionCount: parseInt(newDay.questionCount, 10) || 20,
        },
      );
      const created = (res.data as { data: ScheduleDay }).data ?? (res.data as ScheduleDay);
      setSchedule((prev) => {
        const idx = prev.findIndex((d) => d.quizDay === created.quizDay);
        if (idx >= 0) {
          const next = [...prev];
          next[idx] = created;
          return next;
        }
        return [...prev, created].sort((a, b) => a.quizDay - b.quizDay);
      });
      setNewDay({ quizDay: '', quizDate: '', questionCount: '20' });
      toast.success(`Day ${created.quizDay} assigned`);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to assign day');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="space-y-6 max-w-2xl">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Quiz Schedule</h1>
          <p className="text-muted-foreground">
            League #{leagueId} — assign a quiz date to each day
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={() => window.history.back()}>
          ← Back
        </Button>
      </div>

      {/* Add day form */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Plus className="h-4 w-4" />
            Assign / Update Day
          </CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleAssign} className="grid gap-4 sm:grid-cols-4">
            <div className="space-y-1">
              <Label htmlFor="quizDay">Day #</Label>
              <Input
                id="quizDay"
                type="number"
                min={1}
                max={365}
                placeholder="1"
                value={newDay.quizDay}
                onChange={(e) => setNewDay((p) => ({ ...p, quizDay: e.target.value }))}
                required
              />
            </div>
            <div className="space-y-1 sm:col-span-2">
              <Label htmlFor="quizDate">Date</Label>
              <Input
                id="quizDate"
                type="date"
                value={newDay.quizDate}
                onChange={(e) => setNewDay((p) => ({ ...p, quizDate: e.target.value }))}
                required
              />
            </div>
            <div className="space-y-1">
              <Label htmlFor="questionCount">Questions</Label>
              <Input
                id="questionCount"
                type="number"
                min={1}
                max={100}
                value={newDay.questionCount}
                onChange={(e) => setNewDay((p) => ({ ...p, questionCount: e.target.value }))}
              />
            </div>
            <div className="sm:col-span-4 flex justify-end">
              <Button type="submit" disabled={saving}>
                {saving ? 'Saving…' : 'Save Day'}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      {/* Schedule table */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Calendar className="h-4 w-4" />
            Assigned Days
            <Badge variant="secondary">{schedule.length}</Badge>
          </CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-sm text-muted-foreground">Loading…</p>
          ) : schedule.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              No days assigned yet. Use the form above to add the first day.
            </p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b">
                    <th className="pb-2 text-left font-medium pr-4">Day</th>
                    <th className="pb-2 text-left font-medium pr-4">Date</th>
                    <th className="pb-2 text-left font-medium pr-4">Questions</th>
                    <th className="pb-2 text-left font-medium pr-4">Assigned At</th>
                    <th className="pb-2 text-left font-medium">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {schedule.map((day) => (
                    <tr key={day.id} className="border-b last:border-0">
                      <td className="py-2 pr-4 font-medium">{day.quizDay}</td>
                      <td className="py-2 pr-4">{day.quizDate ?? '—'}</td>
                      <td className="py-2 pr-4">{day.questionCount}</td>
                      <td className="py-2 pr-4 text-muted-foreground text-xs">
                        {day.dateAssigned
                          ? new Date(day.dateAssigned).toLocaleDateString()
                          : '—'}
                      </td>
                      <td className="py-2">
                        <Link
                          href={`/leagues/${leagueId}/quiz-days/${day.id}/questions`}
                          className={buttonVariants({ variant: 'outline', size: 'sm' })}
                        >
                          Manage Questions
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
