# glua-function-reconstructor

This will not work on C functions or localized functions

# Info
This will attempt to reconstruct any valid function you pass to it, generally it should return semi-readable code

# Usage
dump_function( function_name )

Replace function_name with whatever function you want to rebuild


# Output
dump_function(net.WriteTable)

```lua
function net.WriteTable( tab )
 for k, v in pairs( cant locate ) do 
   net.WriteType( v )
   net.WriteType( v )
 end
end
```
