import { LeagueForm } from '../league-form';

export default function NewLeaguePage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">New League</h1>
        <p className="text-muted-foreground">Create a new league.</p>
      </div>
      <LeagueForm />
    </div>
  );
}
