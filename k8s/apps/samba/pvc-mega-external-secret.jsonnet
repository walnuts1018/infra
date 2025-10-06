std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'pvc-mega.jsonnet').metadata.name,
  namespace: (import 'pvc-mega.jsonnet').metadata.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'CRYPTO_KEY_VALUE',
      remoteRef: {
        key: 'samba',
        property: 'longhorn-encryption-key',
      },
    },
  ],
}, {
  spec: {
    target: {
      template: {
        engineVersion: 'v2',
        type: 'Opaque',
        data: {
          CRYPTO_KEY_VALUE: '{{ .CRYPTO_KEY_VALUE }}',
          CRYPTO_KEY_PROVIDER: 'secret',
          CRYPTO_KEY_CIPHER: 'aes-xts-plain64',
          CRYPTO_KEY_HASH: 'sha256',
          CRYPTO_KEY_SIZE: '256',
          CRYPTO_PBKDF: 'argon2i',
        },
      },
    },
  },
})
