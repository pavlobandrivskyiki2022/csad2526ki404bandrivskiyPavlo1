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
include(CTest)
enable_testing()

find_package(Threads REQUIRED)

find_package(GTest QUIET)

if (GTest_FOUND)
    add_executable(unit_tests
        tests/unit_tests.cpp
        math_operations.cpp
    )
    target_include_directories(unit_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
    target_link_libraries(unit_tests PRIVATE GTest::gtest_main GTest::gtest Threads::Threads)

    add_test(NAME BasicAddition COMMAND unit_tests)

else()
    include(FetchContent)
    cmake_policy(SET CMP0135 NEW)

    set(BUILD_GMOCK OFF CACHE BOOL "Build GoogleMock" FORCE)
    set(BUILD_GTEST ON  CACHE BOOL "Build GoogleTest" FORCE)

    FetchContent_Declare(
      googletest
      URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
      DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    )
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

    FetchContent_MakeAvailable(googletest)

    add_executable(unit_tests
        tests/unit_tests.cpp
        math_operations.cpp
    )
    target_include_directories(unit_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

    if (TARGET GTest::gtest_main)
        target_link_libraries(unit_tests PRIVATE GTest::gtest_main GTest::gtest Threads::Threads)
    elseif (TARGET gtest_main)
        target_link_libraries(unit_tests PRIVATE gtest_main gtest Threads::Threads)
    else()
        message(FATAL_ERROR "GTest targets not found after FetchContent_MakeAvailable(googletest)")
    endif()

    add_test(NAME BasicAddition COMMAND unit_tests)
endif()