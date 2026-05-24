---
description: "Use when creating or modifying Next.js admin panel code in apps/admin/. Covers App Router structure, server vs client components, API calls with auth, data tables, forms, and admin role enforcement."
applyTo: "**/apps/admin/**/*.{ts,tsx}"
---

# Next.js Admin Panel Rules

## App Router Structure

```
app/
├── (auth)/              ← unauthenticated routes (login)
│   └── login/
│       └── page.tsx
├── layout.tsx           ← root layout with auth check + sidebar
├── dashboard/page.tsx
├── users/
│   ├── page.tsx         ← list page (server component)
│   └── [id]/page.tsx    ← detail page
└── questions/
    ├── page.tsx
    └── new/page.tsx
```

## Server vs Client Components

- **Default: Server Components** — fetch data on the server, pass as props.
- Use `'use client'` only for interactive UI: forms, modals, tables with sorting/filtering.
- Never fetch data in a client component — pass it from the server component as props.

```tsx
// app/users/page.tsx — Server Component (default)
export default async function UsersPage() {
  const users = await getUsers(); // server-side fetch
  return <UsersTable users={users} />; // UsersTable is a client component
}
```

## Data Fetching

Use `fetch` with Next.js cache tags for server components:

```tsx
async function getUsers() {
  const res = await fetch(`${process.env.API_URL}/v2/admin/users`, {
    headers: { Authorization: `Bearer ${await getAdminToken()}` },
    next: { tags: ['users'], revalidate: 60 },
  });
  if (!res.ok) throw new Error('Failed to fetch users');
  const json = await res.json();
  return json.data; // unwrap the { success, data } envelope
}
```

For client-side mutations, use `axios` with the `useApiClient` hook (which attaches the Firebase token automatically).

## Forms

Use React Hook Form + Zod for all forms:

```tsx
'use client';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  coins: z.number().int().min(0),
});

type FormData = z.infer<typeof schema>;
```

## Admin Auth & Role Enforcement

- All admin routes are protected by NextAuth.js middleware in `middleware.ts`.
- The session contains the user's `role` field from the DB.
- Enforce role access in server components:

```tsx
import { getServerSession } from 'next-auth';
import { redirect } from 'next/navigation';

export default async function SchoolsPage() {
  const session = await getServerSession();
  if (!session || !['super_admin', 'school_admin'].includes(session.user.role)) {
    redirect('/dashboard');
  }
  // ...
}
```

## Data Tables

Use TanStack Table v8 with shadcn/ui `Table` component:

- Always include: column headers with sort, pagination controls, search input.
- For large datasets, always paginate server-side (pass `page` + `limit` to the API).
- Show a loading skeleton while data is fetching, not a spinner.

## UI Components

- Use shadcn/ui components as the base — do not build custom primitives.
- Use Tailwind CSS for all styling — no inline styles, no CSS modules for new code.
- Dark mode is not required in Phase 2; do not add it unless asked.

## API Response Handling

The NestJS API always returns `{ success: boolean, data: T, message: string }`. Always unwrap:

```tsx
const response = await axios.get('/v2/admin/users');
if (!response.data.success) throw new Error(response.data.message);
const users = response.data.data;
```

## Security

- Admin panel must be served over HTTPS only.
- Never embed API keys or secrets in client-side code.
- Use environment variables prefixed `NEXT_PUBLIC_` only for values safe to expose to the browser.
- All admin state-changing actions (suspend user, delete question, distribute prizes) must require a confirmation dialog before executing.
