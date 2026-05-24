---
description: "Scaffold a complete Next.js admin panel page with a server component, data table, and any required forms. Follows mQuiz admin panel conventions."
---

Scaffold a new admin panel page for the mQuiz admin.

Page name: **${input:pageName}**  
API endpoint to fetch data from: **${input:apiEndpoint}**  
Admin roles allowed: **${input:allowedRoles}**  
Brief description: **${input:description}**

## Target Location

`apps/admin/src/app/${input:pageName}/`

## What to Generate

1. **`page.tsx`** (Server Component)
   - Fetch data from `${input:apiEndpoint}` using the admin API client
   - Check session role against `${input:allowedRoles}` — redirect to `/dashboard` if unauthorized
   - Pass data as props to the table client component
   - Include proper loading and error states using Next.js `error.tsx` / `loading.tsx` conventions

2. **`${input:pageName}-table.tsx`** (Client Component `'use client'`)
   - TanStack Table v8 with shadcn/ui `Table` components
   - Include column definitions with sorting
   - Include a search/filter input
   - Include pagination controls (server-side pagination — pass page state to parent via URL params)

3. **`${input:pageName}-columns.tsx`**
   - Column definitions separated for clarity
   - Include an "Actions" column with a dropdown menu (View, Edit, Suspend/Delete as appropriate)
   - All destructive actions must have a `ConfirmDialog` wrapper

4. **`loading.tsx`** — skeleton loader matching the table layout

5. **`error.tsx`** — error boundary with a retry button

## Conventions to Follow

- All data fetching in the Server Component only.
- Use `next: { tags: ['${input:pageName}'] }` on the fetch for cache invalidation.
- Unwrap the NestJS envelope: `const items = response.data.data`.
- Use `revalidatePath` or `revalidateTag` after mutation actions.
- Confirm destructive actions (delete, suspend) before executing.
- Use Zod schemas for any forms on this page.
- Role check must happen server-side, not only client-side.

## After Generating

Remind me to:
1. Add a link to this page in the admin sidebar navigation component.
2. Add the page to the role-permission matrix in `apps/admin/src/lib/permissions.ts`.
3. Test that unauthorized roles are correctly redirected.
