import { apiServer } from '@/lib/api-server';
import type { CoinPack } from '@/types/api';
import { CoinStoreManager } from './coin-store-manager';

async function getCoinPacks(): Promise<CoinPack[]> {
  return apiServer.get<CoinPack[]>('/v2/admin/coin-store', {
    tags: ['coin-store'],
    revalidate: 30,
  });
}

export default async function CoinStorePage() {
  let packs: CoinPack[] = [];
  try {
    packs = await getCoinPacks();
  } catch {
    // render empty state on failure
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Coin Store</h1>
        <p className="text-muted-foreground">
          Manage IAP coin packs available to mobile users.
        </p>
      </div>
      <CoinStoreManager initialPacks={packs} />
    </div>
  );
}
