cmake_minimum_required(VERSION 3.10)

# Set the project name
project(SimpleProject VERSION 1.0 LANGUAGES CXX)
# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Add a custom target to build the Ruby gem
add_custom_target(build_gem
  COMMAND gem build gv_fsm.gemspec && gem install ./gv_fsm-0.4.0.gem 
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  COMMENT "Building Ruby gem gv_fsm.gemspec"
)

add_custom_target(gv_fsm
  COMMAND gv_fsm -k stop --cpp simple.dot
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  COMMENT "Creating simple.cpp from simple.dot"
)

# Add the executable
add_executable(simple simple.cpp)
target_compile_definitions(simple PRIVATE -DTEST_MAIN)

add_dependencies(gv_fsm build_gem)
add_dependencies(simple gv_fsm)