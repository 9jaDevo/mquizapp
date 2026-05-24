import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { QuestionForm } from '@/app/(dashboard)/questions/question-form';

vi.mock('next/navigation', () => ({
  useRouter: () => ({ push: vi.fn(), back: vi.fn(), refresh: vi.fn() }),
}));

vi.mock('@/hooks/use-api-client', () => ({
  useApiClient: () => ({
    post: vi.fn().mockResolvedValue({ data: { success: true } }),
    put: vi.fn().mockResolvedValue({ data: { success: true } }),
  }),
}));

const mockCategories = [
  { id: 1, name: 'Science', categoryImage: '' },
  { id: 2, name: 'Mathematics', categoryImage: '' },
];

const mockQuestion = {
  id: 1,
  category: 1,
  subcategory: 0,
  languageId: 0,
  image: '',
  question: 'What is H2O?',
  questionType: 0,
  optiona: 'Water',
  optionb: 'Fire',
  optionc: 'Air',
  optiond: 'Earth',
  optione: null as string | null,
  answer: 'a',
  level: 1,
  note: '',
};

describe('QuestionForm', () => {
  it('renders all four option input fields', () => {
    render(<QuestionForm categories={mockCategories} />);
    expect(screen.getByLabelText('Option A')).toBeInTheDocument();
    expect(screen.getByLabelText('Option B')).toBeInTheDocument();
    expect(screen.getByLabelText('Option C')).toBeInTheDocument();
    expect(screen.getByLabelText('Option D')).toBeInTheDocument();
  });

  it('renders the question textarea', () => {
    render(<QuestionForm categories={mockCategories} />);
    expect(screen.getByPlaceholderText(/enter the question/i)).toBeInTheDocument();
  });

  it('renders "Create Question" submit button for new question', () => {
    render(<QuestionForm categories={mockCategories} />);
    expect(screen.getByRole('button', { name: /create question/i })).toBeInTheDocument();
  });

  it('renders "Update Question" submit button when editing', () => {
    render(<QuestionForm categories={mockCategories} question={mockQuestion} />);
    expect(screen.getByRole('button', { name: /update question/i })).toBeInTheDocument();
  });

  it('pre-fills question text when editing', () => {
    render(<QuestionForm categories={mockCategories} question={mockQuestion} />);
    const textarea = screen.getByPlaceholderText(/enter the question/i) as HTMLTextAreaElement;
    expect(textarea.value).toBe('What is H2O?');
  });

  it('pre-fills option fields when editing', () => {
    render(<QuestionForm categories={mockCategories} question={mockQuestion} />);
    expect((screen.getByLabelText('Option A') as HTMLInputElement).value).toBe('Water');
    expect((screen.getByLabelText('Option B') as HTMLInputElement).value).toBe('Fire');
  });

  it('renders Cancel button', () => {
    render(<QuestionForm categories={mockCategories} />);
    expect(screen.getByRole('button', { name: /cancel/i })).toBeInTheDocument();
  });
});
