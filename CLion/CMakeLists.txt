cmake_minimum_required(VERSION 3.17)
project(CLion)

set(CMAKE_CXX_STANDARD 14)

include_directories(${PROJECT_SOURCE_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ../../Godot/bin)

add_library(NN STATIC ${PROJECT_SOURCE_DIR}/src/NN/neural_network.cpp src/NN/boilerplate.cpp)

#set(SOURCE_FILES
#        ${PROJECT_SOURCE_DIR}/src/simple.c
#        ${PROJECT_SOURCE_DIR}/src/main.cpp
#)
add_library(CLion SHARED ${PROJECT_SOURCE_DIR}/src/main.cpp ${PROJECT_SOURCE_DIR}/src/simple.c ${PROJECT_SOURCE_DIR}/gdnative_api_struct.gen.h)
target_link_libraries(CLion NN)
