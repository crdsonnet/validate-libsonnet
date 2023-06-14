local params = import 'params.libsonnet';

// Examples checks:

local customCheck(value) =
  std.member(['a', 'b'], value);

local stringMaxLengthCheck(value) =
  local schema = { type: 'string', maxLength: 1 };
  params.schemaCheck(value, schema);

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
      assert params.checkFromDocstring(
        [num, str, enum],
        root['#f'],
      ) : 'Invalid parameters for function "f"',
    },

  return: self.f(1, 1, 'c'),
}
