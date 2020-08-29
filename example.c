// Finite State Machine
// Project: sm.dot
// Description: <none given>
//
// Generated by gv_fsm ruby gem, see https://rubygems.org/gems/gv_fsm
// gv_fsm version 0.0.2
// Generation date: 2020-08-29 15:08:12 +0200
// Generated from: sm.dot
// The finite state machine has:
//   5 states
//   7 transitions

#include <syslog.h>
#include "example.h"

// State functions

state_t do_init(void *data) {
  state_t next_state = STATE_IDLE;

  syslog(LOG_INFO, "[FSM] In state init");
  /* Your code here */
  
  // valid return states: STATE_IDLE
  switch (next_state) {
    case STATE_IDLE:
      break;
    default:
      syslog(LOG_WARNING, "[FSM] Cannot pass from init to %s, remaining in this state", state_names[next_state]);
      next_state = NO_CHANGE;
  }
  return next_state;
}


state_t do_idle(void *data) {
  state_t next_state = NO_CHANGE;

  syslog(LOG_INFO, "[FSM] In state idle");
  /* Your code here */
  
  // valid return states: NO_CHANGE, STATE_IDLE, STATE_SETUP
  switch (next_state) {
    case NO_CHANGE:
    case STATE_IDLE:
    case STATE_SETUP:
      break;
    default:
      syslog(LOG_WARNING, "[FSM] Cannot pass from idle to %s, remaining in this state", state_names[next_state]);
      next_state = NO_CHANGE;
  }
  return next_state;
}


state_t do_setup(void *data) {
  state_t next_state = STATE_RUNNING;

  syslog(LOG_INFO, "[FSM] In state setup");
  /* Your code here */
  
  // valid return states: STATE_RUNNING
  switch (next_state) {
    case STATE_RUNNING:
      break;
    default:
      syslog(LOG_WARNING, "[FSM] Cannot pass from setup to %s, remaining in this state", state_names[next_state]);
      next_state = NO_CHANGE;
  }
  return next_state;
}


state_t do_running(void *data) {
  state_t next_state = NO_CHANGE;

  syslog(LOG_INFO, "[FSM] In state running");
  /* Your code here */
  
  // valid return states: NO_CHANGE, STATE_IDLE, STATE_RUNNING, STATE_STOP
  switch (next_state) {
    case NO_CHANGE:
    case STATE_IDLE:
    case STATE_RUNNING:
    case STATE_STOP:
      break;
    default:
      syslog(LOG_WARNING, "[FSM] Cannot pass from running to %s, remaining in this state", state_names[next_state]);
      next_state = NO_CHANGE;
  }
  return next_state;
}


state_t do_stop(void *data) {
  state_t next_state = NO_CHANGE;

  syslog(LOG_INFO, "[FSM] In state stop");
  /* Your code here */
  
  // valid return states: NO_CHANGE
  switch (next_state) {
    case NO_CHANGE:
      break;
    default:
      syslog(LOG_WARNING, "[FSM] Cannot pass from stop to %s, remaining in this state", state_names[next_state]);
      next_state = NO_CHANGE;
  }
  return next_state;
}


// Transition functions
void init_to_idle(void *data) {
  syslog(LOG_INFO, "[FSM] State transition init_to_idle");
  /* Your code here */
}

void stay(void *data) {
  syslog(LOG_INFO, "[FSM] State transition stay");
  /* Your code here */
}

void to_setup(void *data) {
  syslog(LOG_INFO, "[FSM] State transition to_setup");
  /* Your code here */
}

void setup_to_running(void *data) {
  syslog(LOG_INFO, "[FSM] State transition setup_to_running");
  /* Your code here */
}

void to_idle(void *data) {
  syslog(LOG_INFO, "[FSM] State transition to_idle");
  /* Your code here */
}


// State manager
state_t run_state(state_t cur_state, void *data) {
  state_t new_state = state_table[cur_state](data);
  transition_func_t *transition = transition_table[cur_state][new_state];
  if (transition)
    transition(data);
  return new_state == NO_CHANGE ? cur_state : new_state;
};


#ifdef TEST_MAIN
#include <unistd.h>
int main() {
  state_t cur_state = STATE_INIT;
  openlog("SM", LOG_PID | LOG_PERROR, LOG_USER);
  syslog(LOG_INFO, "Starting SM");
  do {
    cur_state = run_state(cur_state, NULL);
    sleep(1);
  } while (cur_state != STATE_STOP);
  return 0;
}
#endif
