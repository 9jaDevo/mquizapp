import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

export default function SchoolsPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <h1 className="text-2xl font-bold">Schools</h1>
        <Badge variant="secondary">Phase 4</Badge>
      </div>
      <p className="text-muted-foreground">
        School management features are planned for Phase 4 of the mQuiz roadmap.
      </p>
      <Card>
        <CardHeader>
          <CardTitle>Coming Soon</CardTitle>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground space-y-2">
          <p>School management will include:</p>
          <ul className="list-disc list-inside space-y-1">
            <li>School registration and verification</li>
            <li>Student/teacher role management</li>
            <li>Class quizzes and performance reports</li>
            <li>Curriculum-aligned question banks</li>
          </ul>
        </CardContent>
      </Card>
    </div>
  );
}
