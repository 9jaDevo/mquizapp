'use client';

import * as React from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface ConfirmDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description: string;
  /** If set, the user must type this word (e.g. "DELETE") to confirm */
  confirmWord?: string;
  onConfirm: () => void | Promise<void>;
  isPending?: boolean;
  variant?: 'destructive' | 'default';
  confirmLabel?: string;
}

export function ConfirmDialog({
  open,
  onOpenChange,
  title,
  description,
  confirmWord,
  onConfirm,
  isPending = false,
  variant = 'default',
  confirmLabel = 'Confirm',
}: ConfirmDialogProps) {
  const [inputValue, setInputValue] = React.useState('');

  const isConfirmDisabled =
    isPending || (confirmWord !== undefined && inputValue !== confirmWord);

  function handleClose(nextOpen: boolean) {
    if (!nextOpen) setInputValue('');
    onOpenChange(nextOpen);
  }

  async function handleConfirm() {
    await onConfirm();
    setInputValue('');
    onOpenChange(false);
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>{description}</DialogDescription>
        </DialogHeader>

        {confirmWord && (
          <div className="space-y-2">
            <Label htmlFor="confirm-input">
              Type <strong>{confirmWord}</strong> to confirm
            </Label>
            <Input
              id="confirm-input"
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              placeholder={confirmWord}
              autoComplete="off"
            />
          </div>
        )}

        <DialogFooter>
          <Button
            variant="outline"
            onClick={() => handleClose(false)}
            disabled={isPending}
          >
            Cancel
          </Button>
          <Button
            variant={variant === 'destructive' ? 'destructive' : 'default'}
            onClick={handleConfirm}
            disabled={isConfirmDisabled}
          >
            {isPending ? 'Processing...' : confirmLabel}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
