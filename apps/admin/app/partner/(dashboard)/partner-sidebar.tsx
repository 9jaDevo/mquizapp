'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  BarChart3,
  LayoutDashboard,
  ListOrdered,
  LogOut,
  Settings,
  Trophy,
  Users,
} from 'lucide-react';
import { signOut } from 'next-auth/react';
import { Button } from '@/components/ui/button';

const NAV = [
  { href: '/partner/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/partner/contests', label: 'Contests', icon: Trophy },
  { href: '/partner/analytics', label: 'Analytics', icon: BarChart3 },
  { href: '/partner/team', label: 'Team', icon: Users },
  { href: '/partner/settings', label: 'Settings', icon: Settings },
] as const;

export function PartnerSidebar() {
  const pathname = usePathname();
  return (
    <aside className="flex h-screen w-56 flex-col border-r bg-card">
      <div className="flex h-14 items-center gap-2 border-b px-4">
        <ListOrdered className="size-5 text-primary" />
        <span className="font-semibold text-sm">Partner Portal</span>
      </div>
      <nav className="flex-1 space-y-1 p-3">
        {NAV.map(({ href, label, icon: Icon }) => (
          <Link
            key={href}
            href={href}
            className={cn(
              'flex items-center gap-2 rounded-md px-3 py-2 text-sm transition-colors hover:bg-muted',
              pathname.startsWith(href) && href !== '/partner/dashboard'
                ? 'bg-muted font-medium'
                : pathname === href
                  ? 'bg-muted font-medium'
                  : 'text-muted-foreground',
            )}
          >
            <Icon className="size-4" />
            {label}
          </Link>
        ))}
      </nav>
      <div className="border-t p-3">
        <Button
          variant="ghost"
          size="sm"
          className="w-full justify-start gap-2 text-muted-foreground"
          onClick={() => void signOut({ callbackUrl: '/partner/auth/login' })}
        >
          <LogOut className="size-4" />
          Sign Out
        </Button>
      </div>
    </aside>
  );
}
