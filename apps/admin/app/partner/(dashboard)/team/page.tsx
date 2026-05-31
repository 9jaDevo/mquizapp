'use client';

import { useEffect, useState } from 'react';
import { partnerApi } from '@/lib/partner-api-client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { toast } from 'sonner';
import { Trash2 } from 'lucide-react';

interface TeamMember { id: number; email: string; displayName: string; role: string; status: string; createdAt: string }

export default function PartnerTeamPage() {
  const [members, setMembers] = useState<TeamMember[]>([]);
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteRole, setInviteRole] = useState('editor');
  const [loading, setLoading] = useState(true);
  const [inviting, setInviting] = useState(false);

  async function load() {
    try {
      const res = await partnerApi.listTeam() as TeamMember[];
      setMembers(res);
    } catch { toast.error('Failed to load team'); }
    finally { setLoading(false); }
  }

  useEffect(() => { void load(); }, []);

  async function handleInvite(e: React.FormEvent) {
    e.preventDefault();
    setInviting(true);
    try {
      await partnerApi.inviteTeamMember(inviteEmail, inviteRole);
      toast.success(`Invitation sent to ${inviteEmail}`);
      setInviteEmail('');
      void load();
    } catch (err) { toast.error((err as Error).message); }
    finally { setInviting(false); }
  }

  async function handleRemove(id: number) {
    if (!confirm('Remove this team member?')) return;
    try {
      await partnerApi.removeTeamMember(id);
      toast.success('Member removed');
      void load();
    } catch (err) { toast.error((err as Error).message); }
  }

  if (loading) return <div className="text-muted-foreground">Loading…</div>;

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Team</h1>

      <div className="overflow-hidden rounded-lg border">
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              <th className="px-4 py-3 text-left font-medium">Email</th>
              <th className="px-4 py-3 text-left font-medium">Role</th>
              <th className="px-4 py-3 text-left font-medium">Status</th>
              <th className="px-4 py-3 text-left font-medium">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {members.map((m) => (
              <tr key={m.id} className="hover:bg-muted/25">
                <td className="px-4 py-3">{m.email}</td>
                <td className="px-4 py-3 capitalize">
                  <Badge variant={m.role === 'owner' ? 'default' : 'secondary'}>{m.role}</Badge>
                </td>
                <td className="px-4 py-3 capitalize">{m.status}</td>
                <td className="px-4 py-3">
                  {m.role !== 'owner' && (
                    <Button size="sm" variant="ghost" className="text-destructive" onClick={() => void handleRemove(m.id)}>
                      <Trash2 className="size-4" />
                    </Button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="rounded-lg border p-5">
        <h2 className="mb-4 text-lg font-semibold">Invite Team Member</h2>
        <form onSubmit={(e) => { void handleInvite(e); }} className="flex gap-3">
          <div className="flex-1 space-y-1">
            <Label htmlFor="inviteEmail">Email</Label>
            <Input
              id="inviteEmail"
              type="email"
              value={inviteEmail}
              onChange={(e) => setInviteEmail(e.target.value)}
              placeholder="colleague@org.com"
              required
            />
          </div>
          <div className="w-36 space-y-1">
            <Label>Role</Label>
            <Select value={inviteRole} onValueChange={setInviteRole}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="admin">Admin</SelectItem>
                <SelectItem value="editor">Editor</SelectItem>
                <SelectItem value="viewer">Viewer</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="flex items-end">
            <Button type="submit" disabled={inviting}>{inviting ? 'Inviting…' : 'Invite'}</Button>
          </div>
        </form>
      </div>
    </div>
  );
}
