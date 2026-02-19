import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface Response<T> {
  success: boolean;
  message?: string;
  data?: T;
  meta?: any;
}

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Response<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T>> {
    return next.handle().pipe(
      map((data) => {
        // If response is already formatted, return as is
        if (data && typeof data === 'object' && 'success' in data) {
          return data;
        }

        // Format response
        const response: Response<T> = {
          success: true,
        };

        if (data && typeof data === 'object') {
          if ('message' in data) {
            response.message = data.message;
          }
          if ('data' in data) {
            response.data = data.data;
          } else {
            response.data = data;
          }
          if ('meta' in data) {
            response.meta = data.meta;
          }
        } else {
          response.data = data;
        }

        return response;
      }),
    );
  }
}
