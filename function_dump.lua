local function dump_function_params(func_call)
  local param_location = 2
  local func_param = debug.getlocal( func_call, 1 )
  local func_params = {}
  while func_param ~= nil do
    table.insert(func_params, func_param)
    func_param = debug.getlocal( func_call, param_location )
    param_location = param_location + 1
  end
  return func_params
end

local function dump_function(func_call)
  local final_output = "function %s( %s )"
  local func_name = ""
  local func_param_string = ""
  for k, v in pairs(_G) do
    if type(v) == "table" then
      for x, y in pairs(v) do
        if (y == func_call) then
          func_name = k.."."..x
        end
      end
    end
    if (v == func_call) then
      func_name = k
    end
  end

  if (!func_name) then error("Couldn't locate function") end

  if (debug.getinfo(func_call).short_src == "[C]") then error("C Function, this cannot be reconstructed") end

  local dumped_params = dump_function_params(func_call)

  func_param_string = table.concat( dumped_params, ", " )
  final_output = string.format(final_output, func_name, func_param_string)

  local variable_location = -1
  local func_variable = jit.util.funck(func_call, variable_location);
  local last_saved_table = nil
  local open_pairs = false
  while func_variable != nil do
    variable_location = variable_location - 1;
    local next_variable = jit.util.funck(func_call, variable_location);
    if _G[func_variable] && isfunction(_G[func_variable]) then
      if (func_variable == "pairs") then
        final_output = string.format("%s\n for k, v in %s( cant locate ) do ", final_output, func_variable)
        open_pairs = true
      else
        if (open_pairs) then
          final_output = string.format("%s\n%s", final_output, "end")
        end
        final_output = string.format("%s\n function %s( %s )", final_output, func_variable, table.concat( dump_function_params(_G[func_variable]), ", " ))
      end
    else
      if (istable(_G[func_variable])) then
        if (next_variable != nil) then
          if (_G[func_variable][next_variable] && isfunction(_G[func_variable][next_variable])) then
            final_output = string.format("%s\n   %s( %s )", final_output, func_variable.."."..next_variable, table.concat( dump_function_params(_G[func_variable][next_variable]), ", " ))
            last_saved_table = func_variable
          end
        end
      else
        if (_G[func_variable] == nil && last_saved_table && _G[last_saved_table][func_variable]) then
          final_output = string.format("%s\n   %s( %s )", final_output, last_saved_table.."."..func_variable, table.concat( dump_function_params(_G[last_saved_table][func_variable]), ", " ))
        else
          final_output = string.format("%s\n     %s", final_output, func_variable)
        end
      end
    end
    func_variable = next_variable;
  end

  if (open_pairs) then
    final_output = string.format("%s\n %s", final_output, "end")
  end

  final_output = string.format("%s\n%s\n", final_output, "end")
  print(final_output)
end
