

#ifndef MACHINE_HPP
#define MACHINE_HPP

#include <csignal>
#include <functional>
#include <iostream>
#include <map>
#include <string>
#include <tuple>

using namespace std::string_literals;

namespace FSM {
using state_fun = std::function<std::string()>;
using transition_fun = std::function<void()>;
using operation_fun = std::function<void()>;
static bool running = true;

template <typename DATA_T> class FiniteStateMachine {

private:
  std::pair<std::string, std::string> _state{"INIT", "INIT"};
  std::map<std::string, state_fun> _states;
  std::map<std::string, std::map<std::string, transition_fun>> _transitions;
  std::function<void()> _timing_func;

public:
  DATA_T *data;

  FiniteStateMachine(DATA_T *data) : data(data) {
    init_states();
    init_transitions();
  }
  ~FiniteStateMachine(){};

  void add_state(std::string name, state_fun func) { _states[name] = func; }

  void add_transition(std::string from, std::string to, transition_fun func) {
    _transitions[from][to] = func;
  }

  void set_timing_function(std::function<void()> timing_func) {
    _timing_func = timing_func;
  }

  void init_states() {
    add_state("INIT", std::bind(&FiniteStateMachine::do_init, this));
    add_state("IDLE", std::bind(&FiniteStateMachine::do_idle, this));
    add_state("STOP", std::bind(&FiniteStateMachine::do_stop, this));
  }

  void init_transitions() {
    add_transition("INIT", "IDLE", std::bind(&FiniteStateMachine::do_idle, this));
    add_transition("IDLE", "STOP", std::bind(&FiniteStateMachine::do_stop, this));
  }

  std::string operator()(std::string state) {
    if (_states.find(state) == _states.end()) {
      throw std::runtime_error("State not found: "s + state);
    }
    return _states[state]();
  }

  void operator()(std::string from, std::string to) {
    if (_transitions.find(from) != _transitions.end()) {
      if (_transitions[from].find(to) != _transitions[from].end()) {
        _transitions[from][to]();
      }
    }
  }

  void run(std::string state, operation_fun operation = nullptr) {
    FSM::running = true;
    std::string prev_state = state;
    _state.first = state;
    _state.second = state;
    std::signal(SIGINT, [](int signum) { FSM::running = false; });

    do {
      (*this)(_state.first, _state.second);
      if (operation) {
        operation();
      }
      _state.first = _state.second;
      _state.second = (*this)(_state.second);
      if (_timing_func) {
        _timing_func();
      }
    } while (_state.second != "TERMINATE");

    std::signal(SIGINT, SIG_DFL);
  }

  void run(operation_fun operation = nullptr) { run("INIT", operation); }

  std::string state() { return _state.second; }

  // States
  std::string do_init() { return "IDLE"; }

  std::string do_idle() { return FSM::running ? "IDLE" : "STOP"; }

  std::string do_stop() { return "TERMINATE"; }
};

}; // namespace FSM

#endif // MACHINE_HPP