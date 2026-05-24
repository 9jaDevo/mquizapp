import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';

interface ErrorEnvelope {
  success: false;
  error: string;
  message: string;
}

const STATUS_TO_CODE: Record<number, string> = {
  400: 'BAD_REQUEST',
  401: 'UNAUTHORIZED',
  403: 'FORBIDDEN',
  404: 'NOT_FOUND',
  409: 'CONFLICT',
  422: 'UNPROCESSABLE_ENTITY',
  429: 'RATE_LIMIT_EXCEEDED',
  500: 'INTERNAL_ERROR',
};

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let errorCode = STATUS_TO_CODE[500];
    let message = 'Internal server error';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const body = exception.getResponse();

      if (typeof body === 'string') {
        message = body;
        errorCode = STATUS_TO_CODE[status] ?? 'ERROR';
      } else if (body && typeof body === 'object') {
        const b = body as Record<string, unknown>;
        // Only adopt the body's `error` if it matches our SCREAMING_SNAKE convention;
        // otherwise it's likely Nest's default human label (e.g. "Not Found").
        if (typeof b.error === 'string' && /^[A-Z][A-Z0-9_]+$/.test(b.error)) {
          errorCode = b.error;
        } else {
          errorCode = STATUS_TO_CODE[status] ?? 'ERROR';
        }

        if (Array.isArray(b.message)) message = b.message.join('; ');
        else if (typeof b.message === 'string') message = b.message;
        else message = STATUS_TO_CODE[status] ?? 'Error';
      }
    } else if (exception instanceof Error) {
      this.logger.error(`Unhandled exception on ${request.method} ${request.url}`, exception.stack);
      message =
        process.env.NODE_ENV === 'production' ? 'Internal server error' : exception.message;
    }

    const envelope: ErrorEnvelope = {
      success: false,
      error: errorCode,
      message,
    };
    response.status(status).json(envelope);
  }
}
