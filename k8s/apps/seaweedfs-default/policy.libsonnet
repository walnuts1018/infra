// Builds SeaweedFS IAM policy documents (AWS-style JSON policies) from the
// compact { effect, actions, buckets|resources } shorthand used in
// _configs/desired-state.json.

local resourceArn(resource) =
  if resource == '*' || std.startsWith(resource, 'arn:') then resource
  else 'arn:aws:s3:::' + resource;

local bucketResources(buckets) =
  [resourceArn(bucket) for bucket in buckets]
  + [resourceArn(bucket + '/*') for bucket in buckets];

// Shorthand action groups so statements can say `Read`/`Write`/... instead
// of spelling out the underlying s3:* action list every time.
local actionAliases = {
  Admin: ['s3:*'],
  List: ['s3:List*'],
  Read: ['s3:Get*'],
  Tagging: ['s3:*Tagging'],
  Write: ['s3:Put*', 's3:Delete*', 's3:AbortMultipartUpload'],
};

local actions(statement) = std.flattenArrays([
  if std.objectHas(actionAliases, action) then actionAliases[action] else [action]
  for action in statement.actions
]);

local resources(statement) =
  if std.objectHas(statement, 'buckets') then bucketResources(statement.buckets)
  else [resourceArn(resource) for resource in statement.resources];

local document(statements) = {
  Version: '2012-10-17',
  Statement: [
    {
      Effect: statement.effect,
      Action: actions(statement),
      Resource: resources(statement),
    }
    for statement in statements
  ],
};

{
  roleArn(name):: 'arn:aws:iam::role/' + name,
  document(statements):: document(statements),
}
