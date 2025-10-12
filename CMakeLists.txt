# Prompt: Generate a simple CMakeLists.txt for a minimal C++ project that builds an executable named 'hello' from main.cpp. Use C++17 and a safe default cmake_minimum_required.
cmake_minimum_required(VERSION 3.10)
project(hello)
set(CMAKE_CXX_STANDARD 17)
add_executable(hello main.cpp)