import { IsArray, IsInt, IsNotEmpty, IsString, MaxLength, Min } from 'class-validator';

export class SubmitPartnerContestDto {
  @IsArray()
  answers: { questionId: number; answer: string }[];

  @IsInt()
  @Min(0)
  durationMs: number;
}

export class JoinWithCodeDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(16)
  code: string;
}
