export function isPasskeySupported(): boolean {
  return typeof window !== 'undefined'
    && !!(window as any).PublicKeyCredential
    && !!navigator.credentials;
}

export function toPublicKeyCreationOptions(options: any): PublicKeyCredentialCreationOptions {
  return {
    ...options,
    challenge: base64UrlToBuffer(options.challenge),
    user: {
      ...options.user,
      id: base64UrlToBuffer(options.user.id)
    },
    excludeCredentials: (options.excludeCredentials || []).map((cred: any) => ({
      ...cred,
      id: base64UrlToBuffer(cred.id)
    }))
  } as PublicKeyCredentialCreationOptions;
}

export function toPublicKeyRequestOptions(options: any): PublicKeyCredentialRequestOptions {
  return {
    ...options,
    challenge: base64UrlToBuffer(options.challenge),
    allowCredentials: (options.allowCredentials || []).map((cred: any) => ({
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

function base64UrlToBuffer(base64url: string): ArrayBuffer {
  const padding = '='.repeat((4 - (base64url.length % 4)) % 4);
  const base64 = (base64url + padding).replace(/-/g, '+').replace(/_/g, '/');
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
