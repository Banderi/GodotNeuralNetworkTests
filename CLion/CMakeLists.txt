cmake_minimum_required(VERSION 3.17)
project(CLion)

set(CMAKE_CXX_STANDARD 14)

include_directories(${PROJECT_SOURCE_DIR}/src ${PROJECT_SOURCE_DIR}/include/core ${PROJECT_SOURCE_DIR}/godot-headers)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ../../Godot/bin)

set(SOURCE_FILES
        ${PROJECT_SOURCE_DIR}/src/gdexample.cpp
        ${PROJECT_SOURCE_DIR}/src/gdlibrary.cpp
)

#add_library(CLion SHARED ${PROJECT_SOURCE_DIR}/src/simple.cpp ${PROJECT_SOURCE_DIR}/gdnative_api_struct.gen.h)
add_library(CLion SHARED ${SOURCE_FILES} ${PROJECT_SOURCE_DIR}/godot-headers/gdnative_api_struct.gen.h)
