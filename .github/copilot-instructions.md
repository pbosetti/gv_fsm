# For C/C++

## Coding preferences

### Languages

Prefer coding in C++20 or C2017 standards. Prefer Clang over gcc on Unix, prefer Visual Studio 18 compiler on Windows. Avoid Cygwin.

Pay attention to portability: code must be valid on macOS, Linux and Windows (11 or later).

Code formatting: indent by two spaces, LLVM style.

### Coding style

In C++:

* use CamelCase for classes and namespaces and GlobalVariables
* use snake_case for methods, variables, and public class member vars
* prepend underscore to private _member_variables
* declare private and protected variables at the end of a class

In C:

* same style for variable and function names as for C++
* adopt an Object Oriented approach: define an opaque struct and then use functions like `myclass_t *obj = myclass_init()`, `myclass_do_something(obj, val)`, etc. 
* avoid typedefs that mask pointers, as in `typdef typ * mytype_t`

### Build system

Prefer CMake, using Ninja as backend.

Default build dir is `build` under project root. Configure with `cmake -Bbuild` and build with `cmake --build build`

Prefer adding dependencies with FetchContent in Cmake.

### Dependencies

Avoid Boost libraries or libraries requiring Boost.

Commonly used libraries:

* `nlohmann/json` for JSON
* `cxxopts` for CLI options
* `rang` for terminal coloring
* `fmt` for text formatting


## Git branches

Put agents work under a `progress/` branch, and never use words as `agent` or `copilot` in the branch name. For example, `progress/agent-1` is not a good name, but `progress/feature-x` is fine.