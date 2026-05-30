'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useSession } from 'next-auth/react';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  HelpCircle,
  Sparkles,
  Tag,
  Trophy,
  Shield,
  Bell,
  BarChart2,
  Megaphone,
  Settings,
  GraduationCap,
  AlertTriangle,
  Store,
  Mountain,
} from 'lucide-react';

// roles: empty array = visible to all roles; non-empty = only those roles (super_admin always sees all)
const navItems = [
  { label: 'Dashboard', href: '/dashboard', icon: LayoutDashboard, roles: [] as string[] },
  {
    label: 'Users',
    href: '/users',
    icon: Users,
    roles: ['super_admin', 'content_admin', 'school_admin', 'support_admin'],
  },
  { label: 'Questions', href: '/questions', icon: HelpCircle, roles: ['super_admin', 'content_admin'] },
  { label: 'AI Questions', href: '/ai-questions', icon: Sparkles, roles: ['super_admin', 'content_admin'] },
  { label: 'Categories', href: '/categories', icon: Tag, roles: ['super_admin', 'content_admin'] },
  { label: 'Contests', href: '/contests', icon: Trophy, roles: ['super_admin', 'content_admin'] },
  { label: 'Leagues', href: '/leagues', icon: Shield, roles: ['super_admin', 'content_admin'] },
  {
    label: 'Progress Stages',
    href: '/progress-stages',
    icon: Mountain,
    roles: ['super_admin', 'content_admin'],
  },
  {
    label: 'Notifications',
    href: '/notifications',
    icon: Bell,
    roles: ['super_admin', 'content_admin', 'school_admin', 'support_admin'],
  },
  { label: 'Analytics', href: '/analytics', icon: BarChart2, roles: ['super_admin', 'finance_admin'] },
  { label: 'Sponsors', href: '/sponsors', icon: Megaphone, roles: ['super_admin', 'finance_admin'] },
  { label: 'Coin Store', href: '/coin-store', icon: Store, roles: ['super_admin', 'finance_admin'] },
  {
    label: 'Fraud Flags',
    href: '/fraud-flags',
    icon: AlertTriangle,
    roles: ['super_admin', 'support_admin'],
  },
  { label: 'Schools', href: '/schools', icon: GraduationCap, roles: ['super_admin', 'school_admin'] },
  { label: 'Settings', href: '/settings', icon: Settings, roles: ['super_admin'] },
];

export function Sidebar() {
  const pathname = usePathname();
  const { data: session } = useSession();
  const role = (session?.user as { role?: string } | undefined)?.role ?? '';

  const visibleItems = navItems.filter(
    (item) => item.roles.length === 0 || role === 'super_admin' || role === 'admin' || item.roles.includes(role),
  );

  return (
    <aside className="flex h-full w-60 flex-col border-r bg-background">
      {/* Brand */}
      <div className="flex h-14 items-center border-b px-4">
        <Link href="/dashboard" className="flex items-center gap-2 font-semibold">
          <span className="text-primary text-xl">mQuiz</span>
          <span className="text-muted-foreground text-sm">Admin</span>
        </Link>
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto px-2 py-3">
        <ul className="space-y-1">
          {visibleItems.map(({ label, href, icon: Icon }) => {
            const isActive =
              href === '/dashboard'
                ? pathname === '/dashboard'
                : pathname.startsWith(href);
            return (
              <li key={href}>
                <Link
                  href={href}
                  className={cn(
                    'flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors',
                    isActive
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
                  )}
                >
                  <Icon className="h-4 w-4 shrink-0" />
                  {label}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>
    </aside>
  );
}
