local checkParameters(o) =
  local failures = [
    'Parameter %s is invalid%s' % [
      n,
      (if (std.isArray(o[n]))
       then ':' + std.join('\n  ', o[n][1:])
       else '.'),
    ]
    for n in std.objectFields(o)
    if (std.isArray(o[n]) && !o[n][0]) || !o[n]
  ];
  local tests = std.all([
    o[n]
    for n in std.objectFields(o)
    if (std.isArray(o[n]) && !o[n][0]) || !o[n]
  ]);
  if tests
  then true
  else
    std.trace(
      std.join(
        '\n  ',
        ['\nInvalid parameters:']
        + failures
      ),
      false
    );

local customCheck(value) =
  std.member(['a', 'b'], value);

local schemaCheck(value) =
  local v = import 'crdsonnet/validate.libsonnet';
  local schema = { type: 'string', maxLength: 1 };
  local indent = '    ';
  [
    v.validate(value, schema),
    '\n%sValue %s MUST match schema:' % [indent, std.manifestJson(value)],
    indent + std.manifestJsonEx(schema, '  ', '\n  ' + indent),
  ];

local f(num, str, enum) =
  {
    assert checkParameters({
      num: std.isNumber(num),
      str: schemaCheck(str),
      enum: customCheck(enum),
    }) : 'Invalid parameters for function "f"',
  };

f(1, 'bddd', 'c')
