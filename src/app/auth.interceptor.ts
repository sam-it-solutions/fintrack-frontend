import { Injectable } from '@angular/core';
import { HttpErrorResponse, HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from '@angular/common/http';
import { Observable, catchError, throwError } from 'rxjs';
import { SessionService } from './session.service';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  constructor(private session: SessionService) {}

  intercept(req: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    return next.handle(req).pipe(
      catchError((error: HttpErrorResponse) => {
        const isAuthEndpoint = req.url.includes('/api/auth/');
        if (error.status === 401 && !isAuthEndpoint) {
          this.session.clear('Sessie verlopen. Log opnieuw in.');
        } else if (error.status === 403 && !isAuthEndpoint) {
          const message = (error.error?.message ?? error.message ?? '').toString().toLowerCase();
          if (message.includes('token') || message.includes('expired') || message.includes('verlopen')) {
            this.session.clear('Sessie verlopen. Log opnieuw in.');
          }
        }
        return throwError(() => error);
      })
    );
  }
}
