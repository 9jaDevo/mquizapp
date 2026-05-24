import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface ApiResponse<T = unknown> {
  success: true;
  data: T;
  message: string;
}

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, ApiResponse<T>> {
  intercept(_context: ExecutionContext, next: CallHandler<T>): Observable<ApiResponse<T>> {
    return next.handle().pipe(
      map((payload) => {
        // Allow handlers to return their own envelope by returning an object with `success` set
        if (
          payload !== null &&
          typeof payload === 'object' &&
          'success' in (payload as object) &&
          typeof (payload as unknown as { success: unknown }).success === 'boolean'
        ) {
          return payload as unknown as ApiResponse<T>;
        }
        return {
          success: true,
          data: payload as T,
          message: 'OK',
        };
      }),
    );
  }
}
