import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SessionService {
  private tokenSubject = new BehaviorSubject<string | null>(
    localStorage.getItem('fintrack_token')
  );

  token$ = this.tokenSubject.asObservable();

  get token(): string | null {
    return this.tokenSubject.value;
  }

  setToken(token: string) {
    localStorage.setItem('fintrack_token', token);
    this.tokenSubject.next(token);
  }

  clear() {
    localStorage.removeItem('fintrack_token');
    this.tokenSubject.next(null);
  }
}
