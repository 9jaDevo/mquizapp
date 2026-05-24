import { apiServer } from '@/lib/api-server';
import type { PaginatedData, Sponsor } from '@/types/api';
import { SponsorsManager } from './sponsors-manager';

async function getSponsors(): Promise<Sponsor[]> {
  const data = await apiServer.get<PaginatedData<Sponsor>>('/v2/admin/sponsors?limit=100', {
    tags: ['sponsors'],
    revalidate: 60,
  });
  return data.items ?? (data as unknown as Sponsor[]);
}

export default async function SponsorsPage() {
  let sponsors: Sponsor[] = [];
  try {
    sponsors = await getSponsors();
  } catch {
    // render empty state
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Sponsors</h1>
        <p className="text-muted-foreground">Manage contest sponsors and ad placements</p>
      </div>
      <SponsorsManager initialSponsors={sponsors} />
    </div>
  );
}
