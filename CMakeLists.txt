# Prompt: Generate a simple CMakeLists.txt for a minimal C++ project that builds an executable named 'hello' from main.cpp. Use C++17 and a safe default cmake_minimum_required.
cmake_minimum_required(VERSION 3.10)
project(hello)
set(CMAKE_CXX_STANDARD 17)
add_executable(hello main.cpp)

# Prompt: Extend this CMakeLists.txt to:
# 1) Fetch GoogleTest using FetchContent or find_package if available.
# 2) enable_testing() and add a test target 'unit_tests' that builds tests/unit_tests.cpp together with math_operations.cpp.
# 3) Link the tests with GTest::gtest_main and add add_test(NAME BasicAddition COMMAND unit_tests).
# 4) Keep the existing 'hello' executable unchanged.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL
)
FetchContent_MakeAvailable(googletest)
enable_testing()
add_executable(unit_tests tests/unit_tests.cpp math_operations.cpp)
target_link_libraries(unit_tests GTest::gtest_main)
add_test(NAME BasicAddition COMMAND unit_tests)