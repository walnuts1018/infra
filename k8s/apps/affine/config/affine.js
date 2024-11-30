AFFiNE.use("redis", {
  /* override options */
});

AFFiNE.use("oauth", {
  providers: {
    oidc: {
      // OpenID Connect
      issuer: "",
      clientId: "",
      clientSecret: "",
      args: {
        scope: "openid email profile",
        claim_id: "preferred_username",
        claim_email: "email",
        claim_name: "name",
      },
    },
  },
});
