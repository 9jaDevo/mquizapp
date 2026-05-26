'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { Upload, Download, CheckCircle, XCircle, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { useApiClient } from '@/hooks/use-api-client';

// ── CSV column order ──────────────────────────────────────────────────────────
// category,subcategory,languageId,question,questionType,optiona,optionb,optionc,
// optiond,optione,answer,level,image,note

const EXPECTED_HEADERS = [
  'category',
  'subcategory',
  'languageId',
  'question',
  'questionType',
  'optiona',
  'optionb',
  'optionc',
  'optiond',
  'optione',
  'answer',
  'level',
  'image',
  'note',
] as const;

const TEMPLATE_ROW =
  '1,0,0,What is 2+2?,0,4,3,2,1,,a,1,,Example note';

type ParsedQuestion = {
  category: number;
  subcategory: number;
  languageId: number;
  question: string;
  questionType: number;
  optiona: string;
  optionb: string;
  optionc: string;
  optiond: string;
  optione?: string;
  answer: string;
  level: number;
  image?: string;
  note?: string;
};

type RowError = { row: number; message: string };

function parseCSV(text: string): {
  questions: ParsedQuestion[];
  errors: RowError[];
} {
  const lines = text.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n');
  if (lines.length === 0) return { questions: [], errors: [] };

  const header = lines[0].split(',').map((h) => h.trim().toLowerCase());
  const missingHeaders = EXPECTED_HEADERS.filter(
    (h) => !header.includes(h),
  ).filter((h) => !['optione', 'image', 'note'].includes(h)); // optional cols

  if (missingHeaders.length > 0) {
    return {
      questions: [],
      errors: [
        { row: 0, message: `Missing required columns: ${missingHeaders.join(', ')}` },
      ],
    };
  }

  const idx = (col: string) => header.indexOf(col);

  const questions: ParsedQuestion[] = [];
  const errors: RowError[] = [];

  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;

    // Simple CSV parse — handles quoted fields
    const cells = parseCsvLine(line);

    const get = (col: string) => (cells[idx(col)] ?? '').trim();
    const getNum = (col: string) => parseInt(get(col), 10);

    const rowNum = i + 1;
    const question = get('question');
    const answer = get('answer');
    const optiona = get('optiona');
    const optionb = get('optionb');
    const optionc = get('optionc');
    const optiond = get('optiond');
    const category = getNum('category');
    const level = getNum('level');

    const rowErrors: string[] = [];
    if (!question || question.length < 3) rowErrors.push('question too short');
    if (!answer) rowErrors.push('answer is required');
    if (!optiona || !optionb || !optionc || !optiond)
      rowErrors.push('options a–d are required');
    if (isNaN(category) || category < 1) rowErrors.push('invalid category');
    if (isNaN(level) || level < 1 || level > 10)
      rowErrors.push('level must be 1–10');

    if (rowErrors.length > 0) {
      errors.push({ row: rowNum, message: rowErrors.join('; ') });
      continue;
    }

    questions.push({
      category,
      subcategory: getNum('subcategory') || 0,
      languageId: getNum('languageId') || 0,
      question,
      questionType: getNum('questionType') || 0,
      optiona,
      optionb,
      optionc,
      optiond,
      optione: get('optione') || undefined,
      answer,
      level,
      image: get('image') || undefined,
      note: get('note') || undefined,
    });
  }

  return { questions, errors };
}

function parseCsvLine(line: string): string[] {
  const result: string[] = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') {
      inQuotes = !inQuotes;
    } else if (ch === ',' && !inQuotes) {
      result.push(current);
      current = '';
    } else {
      current += ch;
    }
  }
  result.push(current);
  return result;
}

// ── Component ─────────────────────────────────────────────────────────────────

export default function ImportQuestionsPage() {
  const router = useRouter();
  const api = useApiClient();
  const [file, setFile] = React.useState<File | null>(null);
  const [preview, setPreview] = React.useState<{
    questions: ParsedQuestion[];
    errors: RowError[];
  } | null>(null);
  const [importing, setImporting] = React.useState(false);
  const [result, setResult] = React.useState<{
    imported: number;
    failed: number;
  } | null>(null);
  const fileRef = React.useRef<HTMLInputElement>(null);

  function downloadTemplate() {
    const header = EXPECTED_HEADERS.join(',');
    const csv = `${header}\n${TEMPLATE_ROW}\n`;
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'mquiz_questions_template.csv';
    a.click();
    URL.revokeObjectURL(url);
  }

  async function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const f = e.target.files?.[0];
    if (!f) return;
    setFile(f);
    setResult(null);
    const text = await f.text();
    setPreview(parseCSV(text));
  }

  async function handleImport() {
    if (!preview || preview.questions.length === 0) return;
    setImporting(true);
    try {
      // Split into batches of 500 (API limit)
      const BATCH = 500;
      let imported = 0;
      let failed = 0;
      for (let i = 0; i < preview.questions.length; i += BATCH) {
        const batch = preview.questions.slice(i, i + BATCH);
        try {
          const res = await api.post<{ imported: number; failed: number }>(
            '/v2/admin/questions/import',
            { questions: batch },
          );
          imported += res.imported ?? batch.length;
          failed += res.failed ?? 0;
        } catch {
          failed += batch.length;
        }
      }
      setResult({ imported, failed });
      toast.success(`Imported ${imported} questions.`);
      if (failed === 0) {
        setTimeout(() => router.push('/questions'), 1500);
      }
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Import failed');
    } finally {
      setImporting(false);
    }
  }

  return (
    <div className="space-y-6 max-w-3xl">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Bulk Import Questions</h1>
          <p className="text-muted-foreground">
            Upload a CSV file to import up to 500 questions at once.
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={downloadTemplate}>
          <Download className="mr-2 h-4 w-4" />
          Download Template
        </Button>
      </div>

      {/* Upload area */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">1. Select CSV file</CardTitle>
        </CardHeader>
        <CardContent>
          <div
            className="flex flex-col items-center justify-center gap-3 rounded-lg border-2 border-dashed border-muted-foreground/30 px-6 py-12 cursor-pointer hover:border-primary/60 transition-colors"
            onClick={() => fileRef.current?.click()}
          >
            <Upload className="h-10 w-10 text-muted-foreground" />
            <p className="text-sm text-muted-foreground">
              {file ? file.name : 'Click to choose a CSV file or drag and drop'}
            </p>
            <input
              ref={fileRef}
              type="file"
              accept=".csv,text/csv"
              className="hidden"
              onChange={handleFileChange}
            />
          </div>
        </CardContent>
      </Card>

      {/* Preview */}
      {preview && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base flex items-center gap-3">
              2. Preview
              <Badge variant="secondary">
                {preview.questions.length} valid
              </Badge>
              {preview.errors.length > 0 && (
                <Badge variant="destructive">
                  {preview.errors.length} errors
                </Badge>
              )}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {preview.errors.length > 0 && (
              <div className="rounded-md bg-destructive/10 p-3 text-sm space-y-1">
                <p className="font-semibold text-destructive flex items-center gap-1">
                  <XCircle className="h-4 w-4" />
                  Row errors (these rows will be skipped)
                </p>
                {preview.errors.slice(0, 10).map((e) => (
                  <p key={e.row} className="text-destructive/80">
                    Row {e.row}: {e.message}
                  </p>
                ))}
                {preview.errors.length > 10 && (
                  <p className="text-muted-foreground">
                    …and {preview.errors.length - 10} more errors
                  </p>
                )}
              </div>
            )}

            {preview.questions.length > 0 ? (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b">
                      <th className="pb-2 text-left font-medium pr-4">#</th>
                      <th className="pb-2 text-left font-medium pr-4">Question</th>
                      <th className="pb-2 text-left font-medium pr-4">Category</th>
                      <th className="pb-2 text-left font-medium pr-4">Level</th>
                      <th className="pb-2 text-left font-medium">Answer</th>
                    </tr>
                  </thead>
                  <tbody>
                    {preview.questions.slice(0, 20).map((q, i) => (
                      <tr key={i} className="border-b last:border-0">
                        <td className="py-2 pr-4 text-muted-foreground">
                          {i + 1}
                        </td>
                        <td className="py-2 pr-4 max-w-xs truncate">
                          {q.question}
                        </td>
                        <td className="py-2 pr-4">{q.category}</td>
                        <td className="py-2 pr-4">{q.level}</td>
                        <td className="py-2">{q.answer}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                {preview.questions.length > 20 && (
                  <p className="mt-2 text-xs text-muted-foreground">
                    Showing 20 of {preview.questions.length} rows
                  </p>
                )}
              </div>
            ) : (
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <AlertCircle className="h-4 w-4" />
                No valid rows to import. Fix the errors above.
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Result */}
      {result && (
        <div className="flex items-center gap-3 rounded-md bg-green-50 border border-green-200 px-4 py-3 text-sm dark:bg-green-900/20 dark:border-green-700">
          <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400 shrink-0" />
          <span>
            <strong>{result.imported}</strong> questions imported.
            {result.failed > 0 && (
              <> <strong className="text-destructive">{result.failed}</strong> failed.</>
            )}
          </span>
        </div>
      )}

      {/* Import button */}
      {preview && preview.questions.length > 0 && !result && (
        <div className="flex justify-end">
          <Button
            onClick={handleImport}
            disabled={importing}
            className="min-w-32"
          >
            {importing ? (
              'Importing…'
            ) : (
              <>
                <Upload className="mr-2 h-4 w-4" />
                Import {preview.questions.length} Questions
              </>
            )}
          </Button>
        </div>
      )}
    </div>
  );
}
