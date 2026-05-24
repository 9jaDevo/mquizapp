import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { ConfirmDialog } from '@/components/confirm-dialog';

describe('ConfirmDialog', () => {
  it('renders title and description when open', () => {
    render(
      <ConfirmDialog
        open={true}
        onOpenChange={() => {}}
        title="Delete Item"
        description="Are you sure?"
        onConfirm={() => {}}
        isPending={false}
        variant="destructive"
        confirmLabel="Delete"
      />,
    );
    expect(screen.getByText('Delete Item')).toBeInTheDocument();
    expect(screen.getByText('Are you sure?')).toBeInTheDocument();
  });

  it('does not render when closed', () => {
    render(
      <ConfirmDialog
        open={false}
        onOpenChange={() => {}}
        title="Hidden Dialog"
        description="Should not appear"
        onConfirm={() => {}}
        isPending={false}
        variant="default"
        confirmLabel="Confirm"
      />,
    );
    expect(screen.queryByText('Hidden Dialog')).not.toBeInTheDocument();
  });

  it('disables confirm button when confirmWord not yet typed', () => {
    render(
      <ConfirmDialog
        open={true}
        onOpenChange={() => {}}
        title="Confirm"
        description="Type DELETE to confirm"
        confirmWord="DELETE"
        onConfirm={() => {}}
        isPending={false}
        variant="destructive"
        confirmLabel="Delete"
      />,
    );
    const button = screen.getByRole('button', { name: /delete/i });
    expect(button).toBeDisabled();
  });
});
