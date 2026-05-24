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
import { Switch } from '@/components/ui/switch';
import { useApiClient } from '@/hooks/use-api-client';

const schema = z.object({
  maintenanceMode: z.boolean(),
  coinsPerCorrectAnswer: z.number().int().min(0),
  livesRestoreHours: z.number().int().min(1),
  maxDailyQuizzes: z.number().int().min(1),
  referralBonusCoins: z.number().int().min(0),
  adFrequency: z.number().int().min(1),
});

type FormData = z.infer<typeof schema>;

export function SettingsForm() {
  const api = useApiClient();
  const [isLoading, setIsLoading] = React.useState(true);

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
    },
  });

  const maintenanceMode = watch('maintenanceMode');

  React.useEffect(() => {
    api
      .get<FormData>('/v2/admin/settings')
      .then((r) => {
        reset(r.data as FormData);
      })
      .catch(() => {
        // use defaults
      })
      .finally(() => setIsLoading(false));
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function onSave(data: FormData) {
    try {
      await api.patch('/v2/admin/settings', data);
      toast.success('Settings saved');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to save settings');
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
    <Card className="max-w-2xl">
      <CardHeader>
        <CardTitle>Platform Settings</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSave)} className="space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <Label className="text-base">Maintenance Mode</Label>
              <p className="text-sm text-muted-foreground">
                Temporarily disable the app for all users
              </p>
            </div>
            <Switch
              checked={maintenanceMode}
              onCheckedChange={(v) => setValue('maintenanceMode', v)}
            />
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="coinsPerCorrectAnswer">Coins per Correct Answer</Label>
              <Input
                id="coinsPerCorrectAnswer"
                type="number"
                min={0}
                {...register('coinsPerCorrectAnswer', { valueAsNumber: true })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="livesRestoreHours">Lives Restore (hours)</Label>
              <Input
                id="livesRestoreHours"
                type="number"
                min={1}
                {...register('livesRestoreHours', { valueAsNumber: true })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="maxDailyQuizzes">Max Daily Quizzes</Label>
              <Input
                id="maxDailyQuizzes"
                type="number"
                min={1}
                {...register('maxDailyQuizzes', { valueAsNumber: true })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="referralBonusCoins">Referral Bonus Coins</Label>
              <Input
                id="referralBonusCoins"
                type="number"
                min={0}
                {...register('referralBonusCoins', { valueAsNumber: true })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="adFrequency">Ad Frequency (every N questions)</Label>
              <Input
                id="adFrequency"
                type="number"
                min={1}
                {...register('adFrequency', { valueAsNumber: true })}
              />
            </div>
          </div>

          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? 'Saving...' : 'Save Settings'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
