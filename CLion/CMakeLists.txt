cmake_minimum_required(VERSION 3.17)
project(CLion)

set(CMAKE_CXX_STANDARD 14)

include_directories(${PROJECT_SOURCE_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ../../Godot/bin)

add_library(CLion SHARED ${PROJECT_SOURCE_DIR}/src/simple.c ${PROJECT_SOURCE_DIR}/gdnative_api_struct.gen.h)
