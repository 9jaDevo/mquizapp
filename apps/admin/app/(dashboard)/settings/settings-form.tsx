'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { Pencil, Check, X } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Separator } from '@/components/ui/separator';
import { useApiClient } from '@/hooks/use-api-client';
import type { SettingRow } from '@/types/api';

const schema = z.object({
  maintenanceMode: z.boolean(),
  coinsPerCorrectAnswer: z.number().int().min(0),
  livesRestoreHours: z.number().int().min(1),
  maxDailyQuizzes: z.number().int().min(1),
  referralBonusCoins: z.number().int().min(0),
  adFrequency: z.number().int().min(1),
  adsEnabled: z.boolean(),
  leaguesEnabled: z.boolean(),
  schoolsEnabled: z.boolean(),
});

type FormData = z.infer<typeof schema>;

/** Parse an array of SettingRow into FormData (uses defaults for missing keys) */
function parseSettings(rows: SettingRow[]): FormData {
  const map: Record<string, string> = {};
  for (const r of rows) map[r.type] = r.message;
  return {
    maintenanceMode: map['maintenance_mode'] === '1',
    coinsPerCorrectAnswer: parseInt(map['coins_per_correct_answer'] ?? '10', 10),
    livesRestoreHours: parseInt(map['lives_restore_hours'] ?? '4', 10),
    maxDailyQuizzes: parseInt(map['max_daily_quizzes'] ?? '20', 10),
    referralBonusCoins: parseInt(map['referral_bonus_coins'] ?? '50', 10),
    adFrequency: parseInt(map['ad_frequency'] ?? '3', 10),
    adsEnabled: map['ads_enabled'] !== '0',
    leaguesEnabled: map['leagues_enabled'] !== '0',
    schoolsEnabled: map['schools_enabled'] === '1',
  };
}

/** Persist a single setting key/value to the backend */
async function saveSetting(api: ReturnType<typeof useApiClient>, type: string, message: string) {
  await api.patch(`/v2/admin/settings/${type}`, { message });
}

// ---------------------------------------------------------------------------
// Raw K/V editor row
// ---------------------------------------------------------------------------
function KvRow({ row, onSaved }: { row: SettingRow; onSaved: (updated: SettingRow) => void }) {
  const api = useApiClient();
  const [editing, setEditing] = React.useState(false);
  const [value, setValue] = React.useState(row.message);
  const [saving, setSaving] = React.useState(false);

  async function handleSave() {
    setSaving(true);
    try {
      await saveSetting(api, row.type, value);
      onSaved({ ...row, message: value });
      setEditing(false);
      toast.success(`Setting "${row.type}" updated`);
    } catch {
      toast.error('Failed to save');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="flex items-center gap-2 py-1.5 border-b last:border-b-0">
      <span className="w-56 text-xs font-mono text-muted-foreground truncate">{row.type}</span>
      {editing ? (
        <>
          <Input
            value={value}
            onChange={(e) => setValue(e.target.value)}
            className="h-7 text-xs flex-1"
            autoFocus
            onKeyDown={(e) => {
              if (e.key === 'Enter') handleSave();
              if (e.key === 'Escape') { setEditing(false); setValue(row.message); }
            }}
          />
          <Button size="icon" variant="ghost" className="h-7 w-7" onClick={handleSave} disabled={saving}>
            <Check className="h-3 w-3 text-green-600" />
          </Button>
          <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => { setEditing(false); setValue(row.message); }}>
            <X className="h-3 w-3" />
          </Button>
        </>
      ) : (
        <>
          <span className="flex-1 text-xs truncate">{row.message || <span className="italic text-muted-foreground">empty</span>}</span>
          <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => setEditing(true)}>
            <Pencil className="h-3 w-3" />
          </Button>
        </>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
export function SettingsForm() {
  const api = useApiClient();
  const [isLoading, setIsLoading] = React.useState(true);
  const [allSettings, setAllSettings] = React.useState<SettingRow[]>([]);

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      maintenanceMode: false,
      coinsPerCorrectAnswer: 10,
      livesRestoreHours: 4,
      maxDailyQuizzes: 20,
      referralBonusCoins: 50,
      adFrequency: 3,
      adsEnabled: true,
      leaguesEnabled: true,
      schoolsEnabled: false,
    },
  });

  const [maintenanceMode, adsEnabled, leaguesEnabled, schoolsEnabled] = watch([
    'maintenanceMode',
    'adsEnabled',
    'leaguesEnabled',
    'schoolsEnabled',
  ]);

  React.useEffect(() => {
    api
      .get('/v2/admin/settings')
      .then((r) => {
        const body = r.data as { settings?: SettingRow[] } | SettingRow[];
        const rows: SettingRow[] = Array.isArray(body)
          ? body
          : (body as { settings?: SettingRow[] }).settings ?? [];
        setAllSettings(rows);
        reset(parseSettings(rows));
      })
      .catch(() => { /* use defaults */ })
      .finally(() => setIsLoading(false));
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function onSave(data: FormData) {
    try {
      const patches: [string, string][] = [
        ['maintenance_mode', data.maintenanceMode ? '1' : '0'],
        ['coins_per_correct_answer', String(data.coinsPerCorrectAnswer)],
        ['lives_restore_hours', String(data.livesRestoreHours)],
        ['max_daily_quizzes', String(data.maxDailyQuizzes)],
        ['referral_bonus_coins', String(data.referralBonusCoins)],
        ['ad_frequency', String(data.adFrequency)],
        ['ads_enabled', data.adsEnabled ? '1' : '0'],
        ['leagues_enabled', data.leaguesEnabled ? '1' : '0'],
        ['schools_enabled', data.schoolsEnabled ? '1' : '0'],
      ];
      await Promise.all(patches.map(([type, message]) => saveSetting(api, type, message)));
      toast.success('Settings saved');
    } catch {
      toast.error('Failed to save settings');
    }
  }

  if (isLoading) {
    return (
      <Card>
        <CardContent className="py-12 text-center text-muted-foreground">
          Loading settings...
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6 max-w-2xl">
      {/* Platform settings */}
      <Card>
        <CardHeader>
          <CardTitle>Platform Settings</CardTitle>
          <CardDescription>Core platform configuration.</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSave)} className="space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <Label className="text-base">Maintenance Mode</Label>
                <p className="text-sm text-muted-foreground">Temporarily disable the app for all users</p>
              </div>
              <Switch checked={maintenanceMode} onCheckedChange={(v) => setValue('maintenanceMode', v)} />
            </div>

            <Separator />

            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="coinsPerCorrectAnswer">Coins per Correct Answer</Label>
                <Input id="coinsPerCorrectAnswer" type="number" min={0}
                  {...register('coinsPerCorrectAnswer', { valueAsNumber: true })} />
                {errors.coinsPerCorrectAnswer && <p className="text-xs text-destructive">{errors.coinsPerCorrectAnswer.message}</p>}
              </div>
              <div className="space-y-2">
                <Label htmlFor="livesRestoreHours">Lives Restore (hours)</Label>
                <Input id="livesRestoreHours" type="number" min={1}
                  {...register('livesRestoreHours', { valueAsNumber: true })} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="maxDailyQuizzes">Max Daily Quizzes</Label>
                <Input id="maxDailyQuizzes" type="number" min={1}
                  {...register('maxDailyQuizzes', { valueAsNumber: true })} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="referralBonusCoins">Referral Bonus Coins</Label>
                <Input id="referralBonusCoins" type="number" min={0}
                  {...register('referralBonusCoins', { valueAsNumber: true })} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="adFrequency">Ad Frequency (every N questions)</Label>
                <Input id="adFrequency" type="number" min={1}
                  {...register('adFrequency', { valueAsNumber: true })} />
              </div>
            </div>

            <Separator />

            <div className="space-y-4">
              <h3 className="text-sm font-semibold">Feature Flags</h3>
              {[
                { key: 'adsEnabled' as const, label: 'Ads', description: 'Enable ad display across the app' },
                { key: 'leaguesEnabled' as const, label: 'Leagues', description: 'Enable the leagues & competitive mode' },
                { key: 'schoolsEnabled' as const, label: 'Schools', description: 'Enable schools module (Phase 4+)' },
              ].map(({ key, label, description }) => (
                <div key={key} className="flex items-center justify-between">
                  <div>
                    <Label className="text-sm">{label}</Label>
                    <p className="text-xs text-muted-foreground">{description}</p>
                  </div>
                  <Switch
                    checked={watch(key)}
                    onCheckedChange={(v) => setValue(key, v)}
                  />
                </div>
              ))}
            </div>

            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Saving…' : 'Save Settings'}
            </Button>
          </form>
        </CardContent>
      </Card>

      {/* Raw K/V editor */}
      {allSettings.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>All Settings (Raw)</CardTitle>
            <CardDescription>Edit any setting value inline. Changes are saved immediately.</CardDescription>
          </CardHeader>
          <CardContent>
            {allSettings.map((row) => (
              <KvRow
                key={row.id}
                row={row}
                onSaved={(updated) =>
                  setAllSettings((prev) => prev.map((r) => (r.id === updated.id ? updated : r)))
                }
              />
            ))}
          </CardContent>
        </Card>
      )}
    </div>
  );
}
