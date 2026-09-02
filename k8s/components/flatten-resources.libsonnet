function(resources)
  std.flattenArrays([
    if std.isArray(v) then v else [v]
    for v in std.objectValues(resources)
  ])
