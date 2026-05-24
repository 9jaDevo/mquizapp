import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { DataTable } from '@/components/data-table';
import type { ColumnDef } from '@tanstack/react-table';

interface Row { id: number; name: string }

const columns: ColumnDef<Row>[] = [
  { accessorKey: 'id', header: 'ID' },
  { accessorKey: 'name', header: 'Name' },
];

describe('DataTable', () => {
  it('renders column headers', () => {
    render(
      <DataTable
        columns={columns}
        data={[]}
        searchColumn="name"
        searchPlaceholder="Search..."
      />,
    );
    expect(screen.getByText('ID')).toBeInTheDocument();
    expect(screen.getByText('Name')).toBeInTheDocument();
  });

  it('shows empty state when no data', () => {
    render(
      <DataTable
        columns={columns}
        data={[]}
        searchColumn="name"
        searchPlaceholder="Search..."
      />,
    );
    expect(screen.getByText(/no results/i)).toBeInTheDocument();
  });

  it('renders rows with data', () => {
    const data: Row[] = [
      { id: 1, name: 'Alice' },
      { id: 2, name: 'Bob' },
    ];
    render(
      <DataTable
        columns={columns}
        data={data}
        searchColumn="name"
        searchPlaceholder="Search..."
      />,
    );
    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('Bob')).toBeInTheDocument();
  });

  it('shows skeleton rows while loading', () => {
    render(
      <DataTable
        columns={columns}
        data={[]}
        isLoading={true}
        searchColumn="name"
        searchPlaceholder="Search..."
      />,
    );
    // skeleton rows have aria-hidden or data-slot="skeleton"
    const skeletons = document.querySelectorAll('[data-slot="skeleton"]');
    expect(skeletons.length).toBeGreaterThan(0);
  });
});
