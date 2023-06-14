{
  local root = self,

  checkParameters(checks):
    local failures = [
      'Parameter %s is invalid%s' % [
        n,
        (if (std.isArray(checks[n]))
         then ':' + std.join('\n  ', checks[n][1:])
         else '.'),
      ]
      for n in std.objectFields(checks)
      if (std.isArray(checks[n]) && !checks[n][0])
        || (std.isBoolean(checks[n]) && !checks[n])
    ];
    local tests = std.all([
      checks[n][0]
      for n in std.objectFields(checks)
      if (std.isArray(checks[n]) && !checks[n][0])
        || (std.isBoolean(checks[n]) && !checks[n])
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
      ),


  checkFromDocstring(params, docstring):
    local args = docstring.args;
    assert std.length(args) == std.length(params)
           : 'checkFromDocstring: expect equal number of args as params';
    local checks = {
      [args[i].name]:
        root.schemaCheck(
          params[i],
          {
            type: args[i].type,
            [if 'enums' in args[i] then 'enum']: args[i].enums,
          }
        )
      for i in std.range(0, std.length(params) - 1)
    };
    root.checkParameters(checks),

  schemaCheck(param, schema):
    local v = import 'crdsonnet/validate.libsonnet';
    local indent = '    ';
    [
      v.validate(param, schema),
      '\n%sValue %s MUST match schema:' % [indent, std.manifestJson(param)],
      indent + std.manifestJsonEx(schema, '  ', '\n  ' + indent),
    ],

}
