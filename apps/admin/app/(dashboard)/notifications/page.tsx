import { NotificationsPanel } from './notifications-panel';

export default function NotificationsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Notifications</h1>
        <p className="text-muted-foreground">Send broadcast push notifications to users</p>
      </div>
      <NotificationsPanel />
    </div>
  );
}
