local checkParameters(o) =
  local failures = [
    'Parameter %s is invalid%s' % [
      n,
      (if (std.isArray(o[n]))
       then ':' + std.join('\n  ', o[n][1:])
       else '.'),
    ]
    for n in std.objectFields(o)
    if (std.isArray(o[n]) && !o[n][0])
        || (std.isBoolean(o[n]) && !o[n])
  ];
  local tests = std.all([
    o[n][0]
    for n in std.objectFields(o)
    if (std.isArray(o[n]) && !o[n][0])
        || (std.isBoolean(o[n]) && !o[n])
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

local schemaCheck(value, schema) =
  local v = import 'crdsonnet/validate.libsonnet';
  local indent = '    ';
  [
    v.validate(value, schema),
    '\n%sValue %s MUST match schema:' % [indent, std.manifestJson(value)],
    indent + std.manifestJsonEx(schema, '  ', '\n  ' + indent),
  ];

local stringMaxLengthCheck(value) =
  local schema = { type: 'string', maxLength: 1 };
  schemaCheck(value, schema);

local checkFromDocstring(values, docstring) =
  local args = docstring.args;
  {
    [args[i].name]:
      schemaCheck(
        values[i],
        {
          type: args[i].type,
          [if 'enums' in args[i] then 'enum']: args[i].enums,
        }
      )
    for i in std.range(0, std.length(values) - 1)
  };

{
  local root = self,
  '#f':: {
    args: [
      { name: 'num', type: 'number' },
      { name: 'str', type: 'string' },
      { name: 'enum', type: 'string', enums: ['a', 'b'] },
    ],
  },
  f(num, str, enum)::
    {
      assert checkParameters(
        checkFromDocstring(
          [num, str, enum],
          root['#f'],
        )
      ) : 'Invalid parameters for function "f"',
    },

  return: self.f(1, 1, 'c'),
}
