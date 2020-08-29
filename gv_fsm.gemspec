require File.expand_path("../lib/version.rb", __FILE__)
date = Time.now.strftime("%Y-%m-%m")
Gem::Specification.new do |s|
  s.name        = 'gv_fsm'
  s.version     = GV_FSM::VERSION
  s.date        = date
  s.summary     = "Graphviz to Finite state machine"
  s.description = "A C/C++ code generator that creates code for a finite state machine given a description in graphviz language."
  s.authors     = ["Paolo Bosetti"]
  s.email       = 'paolo.bosetti@unitn.it'
  s.files       = ["lib/gv_fsm.rb", "lib/templates.rb", "lib/version.rb", "bin/gv_fsm"]
  s.homepage    =
    'https://github.com/pbosetti/gv_fsm'
  s.license       = 'MIT'
  s.executables << "gv_fsm"
  s.require_paths = ["lib"]
  s.add_dependency('ruby-graphviz', "~> 1.2.5")
end