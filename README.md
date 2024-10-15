# GV_FSM [![Gem Version](https://badge.fury.io/rb/gv_fsm.svg)](https://badge.fury.io/rb/gv_fsm)

This is a Ruby gem and executable for generating a stub for a Finite State Machine in C/C++ from a scheme written in Graphviz language.

**DISCLAIMER**: You need Ruby for running it, but it runs as a command line executable that transparently uses Ruby for generating C/C++ source code. So **you do not need to know/like Ruby in order to use it**:

## Installation

Simply:

```sh
[sudo] gem install gv_fsm
```

**Warning**: if you are using [rvm](https://rvm.io) or similar tools, the executable is installed in the rvm hidden folders: find where it is with `gem environment` **be sure to have the path for EXECUTABLE DIRECTORY it in your path!**

## Usage

First, you have to create a Graphviz .dot file describing the state machine. Use **directed edges** for transition and follow these conventions:

* States are represented by nodes. Node labels are taken as name of functions called within a state.
* If the state label is missing, the function is generated with the signature `state_t do_<statename>(state_data_t *data)`
* All persistent state data have to be put in the `data` object (typically a C struct)
* `state_data_t` is typedef as `void`: either cast it within each state and transition function, or edit the typedef at the beginning of the header.
* Transitions may have associated functions: if an edge (transition) label is missing, no transition function is generated. If it is present, then the label becomes the name of the function; if the lable is the `#` character, the function is generated with the signature `void <source_state>_to_<dest_state>()`
  
The .dot file can be used for generating C/C++ files with the command:

```sh
gv_fsm scheme.dot
```

This generates a header file (by default with the name `scheme.h`, use the `-s` switch for changing it) and the source file (`scheme.c`). Typically, **you have then to provide the implementation of state and transition functions by only editing the `scheme.c` file**.

The main interface to the FSM in C is the `run_state` function. See at the end of the generated source file for example usage.

## Arduino support

If you need an FSM for your Arduino, you can generate it with the command option `--ino`: this will generate a `.h` and a `.cpp` files, omitting all instructions that are not available on the Arduino (e.g. the `syslog` calls, which are replaced with `Serial.print calls`). Load these files in the IDE, require the header from the main `.ino` file, and call the FSM manager function from within the main `loop()` function.

## NEW in version 0.4

Gem version 0.4 introduces a new CLI option that enables the generation of C++17 code. This is done by adding the `--cpp` option to the command line.

The generated code is easier to use than the C version:

* the `FiniteStateMachine` class is a template class that accepts the state data type as template parameter
* almost all the boilerplate code is hidden in the `FiniteStateMachine` class header file, **including state change checks**. Under normal circumstances, you **do not need to edit** this file
* the source file only has a list of state functions and transition functions, which --- on the contrary of the C version --- are bare functions, since the state change checks are done by the `FiniteStateMachine` class
* in accord to the above, it is easier to update the FSM scheme and regenerate only the header, then manually update the source file with the new/changed/deleted state and transition functions
* the generated state functions return the special state `FSM::UNIMPLEMENTED`, which triggers an exception in the `FiniteStateMachine` class. This is useful for debugging, since it is easy to spot which state has not been implemented yet
* the FiniteStateMachine class has a `run` method that runs the FSM until the exit state (identified as the only sink state in the graph) is reached. This method also accepts a lambda or a `std::function` object that is called at each iteration, and can be used for logging or other purposes
* the `FiniteStateMachine::set_timing_function` method allows to set a function that is called at each iteration for timing purposes


## NEW in version 0.3

Gem version o.3.0 introduces a new CLI option that enables the generation of code that support SIGINT signal management:

```bash
gv_fsm fsm.dot -k stop
```

It defines a handler function and installs it as active signal handler for SIGINT in the source node of the FSM. Then, in every *stable* state (i.e. a state having a transition to itself), it adds a condition to switch to the final state specified by the CLI option (`stop` in the example above) whenever the SIGINT signal has been received.

Please note that the transition is triggered by the global variable `_exit_request`: when it becomes true, all stable states transition to the specified state on the next iteration. Also, note that **non-stable states are not affected by this mechanism**.

If the target state is not a sink (i.e. it has some further exit states), then a warning is produced during code generation, but the code is generated nonetheless.

This option **is not compatible** with the `--ino` option, since signals are not available on that platform.

## Example

See the `sm.dot` file as FSM example, and the generated files `example.{c,h}`. In this example, the same function `stay` is generated from both transitions from idle to idle and from running to running. Also, the name of the transition from setup to running is automatically generated (as `setup_to_running`).
The files `arduino.{cpp,h}` are the corresponding examples generated for the Arduino platform.

![Example graph](example.png)
