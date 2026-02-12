import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SessionService {
  private logoutTimer?: ReturnType<typeof setTimeout>;
  private tokenSubject = new BehaviorSubject<string | null>(
    localStorage.getItem('fintrack_token')
  );
  private noticeSubject = new BehaviorSubject<string | null>(null);

  token$ = this.tokenSubject.asObservable();
  notice$ = this.noticeSubject.asObservable();

  get token(): string | null {
    return this.tokenSubject.value;
  }

  get notice(): string | null {
    return this.noticeSubject.value;
  }

  consumeNotice(): string | null {
    const current = this.noticeSubject.value;
    this.noticeSubject.next(null);
    return current;
  }

  setToken(token: string) {
    localStorage.setItem('fintrack_token', token);
    this.tokenSubject.next(token);
    this.scheduleExpiry(token);
  }

  clear(message?: string) {
    localStorage.removeItem('fintrack_token');
    this.tokenSubject.next(null);
    if (this.logoutTimer) {
      clearTimeout(this.logoutTimer);
      this.logoutTimer = undefined;
    }
    if (message) {
      this.noticeSubject.next(message);
    }
  }

  initialize() {
    const token = this.tokenSubject.value;
    if (!token) {
      return;
    }
    this.scheduleExpiry(token);
  }

  private scheduleExpiry(token: string) {
    if (this.logoutTimer) {
      clearTimeout(this.logoutTimer);
      this.logoutTimer = undefined;
    }
    const expiry = this.getTokenExpiry(token);
    if (!expiry) {
      return;
    }
    const ms = expiry - Date.now();
    if (ms <= 0) {
      return;
    }
    this.logoutTimer = setTimeout(() => {
      this.clear('Sessie verlopen. Log opnieuw in.');
    }, ms);
  }

  private getTokenExpiry(token: string): number | null {
    try {
      const payload = JSON.parse(atob(token.split('.')[1] ?? ''));
      if (typeof payload?.exp !== 'number') {
        return null;
      }
      return payload.exp * 1000;
    } catch {
      return null;
    }
  }
}
