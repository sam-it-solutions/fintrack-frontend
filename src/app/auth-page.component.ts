import { Component } from '@angular/core';
import { ApiService } from './api.service';
import { SessionService } from './session.service';
import { firstValueFrom } from 'rxjs';
import { isPasskeySupported, serializeAssertionCredential, toPublicKeyRequestOptions } from './webauthn.utils';

@Component({
  selector: 'app-auth-page',
  templateUrl: './auth-page.component.html',
  styleUrls: ['./auth-page.component.css']
})
export class AuthPageComponent {
  appName = 'Fintrack';
  subtitle = 'Premium fintech overzicht voor banken en crypto.';

  email = '';
  password = '';
  mode: 'login' | 'register' = 'login';
  statusMessage = '';
  loading = false;
  passkeySupported = isPasskeySupported();
  passkeyBusy = false;

  constructor(private api: ApiService, private session: SessionService) {}

  switchMode(mode: 'login' | 'register') {
    this.mode = mode;
    this.statusMessage = '';
  }

  authenticate() {
    this.loading = true;
    const action = this.mode === 'login'
      ? this.api.login(this.email, this.password)
      : this.api.register(this.email, this.password);

    action.subscribe({
      next: (res) => {
        this.session.setToken(res.token);
        this.statusMessage = 'Welkom terug!';
        this.loading = false;
      },
      error: (err) => {
        this.loading = false;
        this.statusMessage = err?.error?.message ?? 'Login mislukt.';
      }
    });
  }

  async loginWithPasskey() {
    if (!this.passkeySupported) {
      this.statusMessage = 'Face ID is niet beschikbaar op dit toestel.';
      return;
    }
    this.passkeyBusy = true;
    this.statusMessage = '';
    try {
      const start = await firstValueFrom(this.api.passkeyLoginStart(this.email));
      const publicKey = toPublicKeyRequestOptions(start.options);
      const credential = await navigator.credentials.get({ publicKey }) as PublicKeyCredential | null;
      if (!credential) {
        throw new Error('Geen passkey gevonden.');
      }
      const payload = serializeAssertionCredential(credential);
      const result = await firstValueFrom(this.api.passkeyLoginFinish(start.challengeId, payload));
      this.session.setToken(result.token);
      this.statusMessage = 'Welkom terug!';
    } catch (err: any) {
      this.statusMessage = err?.error?.message ?? err?.message ?? 'Face ID login mislukt.';
    } finally {
      this.passkeyBusy = false;
    }
  }
}
