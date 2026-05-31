import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';

export enum OrgType {
  CHURCH = 'church',
  COMPANY = 'company',
  SCHOOL = 'school',
  INDIVIDUAL = 'individual',
  NGO = 'ngo',
  GOVERNMENT = 'government',
}

export class RegisterPartnerDto {
  @IsString()
  @MinLength(2)
  @MaxLength(255)
  orgName: string;

  @IsEnum(OrgType)
  orgType: OrgType;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  @MaxLength(128)
  password: string;

  @IsOptional()
  @IsString()
  @MaxLength(32)
  phone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(3)
  country?: string;
}
