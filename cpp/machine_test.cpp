#include "machine.hpp"
#include <thread>

struct StateData {
  int a;
  int b;
};

using namespace FSM;

int main() {
  StateData data = {1, 2};
  std::string state = "INIT";
  FiniteStateMachine<StateData> fsm{&data};
  fsm.set_timing_function([]() {
    std::this_thread::sleep_for(std::chrono::seconds(1));
  });

  fsm.add_transition("INIT", "IDLE", [&]() {
    std::cout << "Transition from INIT to IDLE" << std::endl;
  });

  fsm.run([&]() {
    std::cout << "State: " << fsm.state() << " data: " << fsm.data->a << std::endl;
  });

  return 0;
}