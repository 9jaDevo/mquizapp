import {
  IsArray,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ArrayMaxSize,
  ArrayMinSize,
} from 'class-validator';

export enum AnswerOption {
  A = 'a',
  B = 'b',
  C = 'c',
  D = 'd',
  E = 'e',
}

export class AddPartnerQuestionDto {
  @IsString()
  questionText: string;

  @IsString()
  optionA: string;

  @IsString()
  optionB: string;

  @IsString()
  optionC: string;

  @IsString()
  optionD: string;

  @IsOptional()
  @IsString()
  optionE?: string;

  @IsEnum(AnswerOption)
  answer: AnswerOption;

  @IsOptional()
  @IsString()
  explanation?: string;

  @IsOptional()
  @IsString()
  @MaxLength(512)
  imageUrl?: string;
}

export class AddQuestionsFromBankDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @IsInt({ each: true })
  @Min(1, { each: true })
  questionIds: number[];
}

export class ReorderQuestionsDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(200)
  @IsInt({ each: true })
  @Min(1, { each: true })
  orderedIds: number[];
}
