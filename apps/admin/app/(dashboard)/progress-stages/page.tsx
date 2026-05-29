import { apiServer } from '@/lib/api-server';
import type { ProgressStage } from '@/types/api';
import { StagesManager } from './stages-manager';

async function getStages(): Promise<ProgressStage[]> {
  return apiServer.get<ProgressStage[]>('/v2/admin/progress-stages', {
    tags: ['progress-stages'],
    revalidate: 30,
  });
}

export default async function ProgressStagesPage() {
  let stages: ProgressStage[] = [];
  try {
    stages = await getStages();
  } catch {
    // render empty state
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Progress Stages</h1>
        <p className="text-muted-foreground">
          Configure XP milestones (e.g., Bronze, Silver, Gold) shown to mobile users.
        </p>
      </div>
      <StagesManager initialStages={stages} />
    </div>
  );
}
