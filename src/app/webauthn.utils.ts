export function isPasskeySupported(): boolean {
  return typeof window !== 'undefined'
    && !!(window as any).PublicKeyCredential
    && !!navigator.credentials;
}

export function toPublicKeyCreationOptions(options: any): PublicKeyCredentialCreationOptions {
  const raw = normalizeOptions(options);
  const payload = raw?.publicKey ?? raw;
  if (!payload?.challenge || !payload?.user?.id) {
    throw new Error('Passkey data ontbreekt. Probeer opnieuw.');
  }
  const exclude = (payload.excludeCredentials || []).filter((cred: any) => !!cred?.id);
  return {
    ...payload,
    challenge: base64UrlToBuffer(payload.challenge),
    user: {
      ...payload.user,
      id: base64UrlToBuffer(payload.user.id)
    },
    excludeCredentials: exclude.map((cred: any) => ({
      ...cred,
      id: base64UrlToBuffer(cred.id)
    }))
  } as PublicKeyCredentialCreationOptions;
}

export function toPublicKeyRequestOptions(options: any): PublicKeyCredentialRequestOptions {
  const raw = normalizeOptions(options);
  const payload = raw?.publicKey ?? raw;
  if (!payload?.challenge) {
    throw new Error('Passkey data ontbreekt. Probeer opnieuw.');
  }
  const allow = (payload.allowCredentials || []).filter((cred: any) => !!cred?.id);
  return {
    ...payload,
    challenge: base64UrlToBuffer(payload.challenge),
    allowCredentials: allow.map((cred: any) => ({
      ...cred,
      id: base64UrlToBuffer(cred.id)
    }))
  } as PublicKeyCredentialRequestOptions;
}

export function serializeRegistrationCredential(cred: PublicKeyCredential): any {
  const response = cred.response as AuthenticatorAttestationResponse;
  return {
    id: cred.id,
    rawId: bufferToBase64Url(cred.rawId),
    type: cred.type,
    response: {
      clientDataJSON: bufferToBase64Url(response.clientDataJSON),
      attestationObject: bufferToBase64Url(response.attestationObject)
    },
    clientExtensionResults: cred.getClientExtensionResults()
  };
}

export function serializeAssertionCredential(cred: PublicKeyCredential): any {
  const response = cred.response as AuthenticatorAssertionResponse;
  return {
    id: cred.id,
    rawId: bufferToBase64Url(cred.rawId),
    type: cred.type,
    response: {
      clientDataJSON: bufferToBase64Url(response.clientDataJSON),
      authenticatorData: bufferToBase64Url(response.authenticatorData),
      signature: bufferToBase64Url(response.signature),
      userHandle: response.userHandle ? bufferToBase64Url(response.userHandle) : null
    },
    clientExtensionResults: cred.getClientExtensionResults()
  };
}

function base64UrlToBuffer(input?: any): ArrayBuffer {
  if (!input) {
    throw new Error('Passkey data ontbreekt. Probeer opnieuw.');
  }
  if (input instanceof ArrayBuffer) {
    return input;
  }
  if (input instanceof Uint8Array) {
    return input.buffer;
  }
  if (Array.isArray(input)) {
    return new Uint8Array(input).buffer;
  }
  if (typeof input === 'object') {
    if (Array.isArray(input.data)) {
      return new Uint8Array(input.data).buffer;
    }
    if (typeof input.base64url === 'string') {
      return base64UrlToBuffer(input.base64url);
    }
    if (typeof input.base64 === 'string') {
      return base64UrlToBuffer(input.base64.replace(/\+/g, '-').replace(/\//g, '_'));
    }
  }
  if (typeof input !== 'string') {
    throw new Error('Passkey data ontbreekt. Probeer opnieuw.');
  }
  const padding = '='.repeat((4 - (input.length % 4)) % 4);
  const base64 = (input + padding).replace(/-/g, '+').replace(/_/g, '/');
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

function bufferToBase64Url(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  bytes.forEach((b) => {
    binary += String.fromCharCode(b);
  });
  const base64 = btoa(binary);
  return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
}

function normalizeOptions(options: any): any {
  if (!options) {
    return null;
  }
  if (typeof options === 'string') {
    try {
      return JSON.parse(options);
    } catch {
      return null;
    }
  }
  return options;
}
