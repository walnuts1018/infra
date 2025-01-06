{
  secretName(username):
    std.join('-', std.split(username, '_')) + '.default.credentials.postgresql.acid.zalan.do',
}
