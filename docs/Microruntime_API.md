# Microruntime API
Microruntimes should provide a standard enviroment for loading modules and running opperating systems, be it from disk or network.
The microruntime should provide two methods: loadmodule and entry.
* envs:loadmodule(string) - String is the name of the module, this should be able to load modules for use in a boot config
* envs:entry(string, function(envs)) - String is the display name of the entry, and the function is the function executed by the entry, passing the enviroment to the function as the first argument.
