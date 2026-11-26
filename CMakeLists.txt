cmake_minimum_required(VERSION 3.25)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if (APPLE)
    if ("${CMAKE_SYSTEM_NAME}" STREQUAL "iOS" OR IOS)
        set(CMAKE_OSX_ARCHITECTURES "arm64")
    else()
        set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")
    endif()
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
endif()

project(P VERSION 1.0.2)

add_library(${PROJECT_NAME} SHARED
    src/main.cpp
)

set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "livebyunix.p")

if (NOT DEFINED ENV{GEODE_SDK})
    message(FATAL_ERROR "Unable to find Geode SDK! Please define GEODE_SDK environment variable to point to Geode")
else()
    message(STATUS "Found Geode: $ENV{GEODE_SDK}")
endif()

add_subdirectory($ENV{GEODE_SDK} ${CMAKE_CURRENT_BINARY_DIR}/geode)

setup_geode_mod(${PROJECT_NAME})

# Unit tests for the gameplay-state decision logic. These do not depend on
# Geode or the game and can run anywhere.
enable_testing()
add_executable(p_tests tests/test_gameplay_check.cpp)
target_include_directories(p_tests PRIVATE src)
add_test(NAME gameplay_check COMMAND p_tests)
