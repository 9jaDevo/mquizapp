import { ContestForm } from '../contest-form';

export default function NewContestPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">New Contest</h1>
        <p className="text-muted-foreground">Create a new contest event.</p>
      </div>
      <ContestForm />
    </div>
  );
}
