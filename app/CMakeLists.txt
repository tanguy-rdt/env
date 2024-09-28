cmake_minimum_required(VERSION 3.20)

project(env_configurator VERSION 1.0
                         DESCRIPTION ""
                         LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG") # cmake -DCMAKE_BUILD_TYPE=Release ..
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG") # cmake -DCMAKE_BUILD_TYPE=Debug ..           

set(DIST_DIR "../dist")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${DIST_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${DIST_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${DIST_DIR})


#
# ADD THIRD_PARTY
# 

add_subdirectory(third-party/json)


#
# ADD .cpp & .h
# 

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

file(GLOB_RECURSE SRC
    ${SRC_DIR}/*.cpp
    ${SRC_DIR}/*.c
)

file(GLOB_RECURSE HEADER_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.h ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
set(INCLUDE_DIRS "")
foreach(HEADER_FILE ${HEADER_FILES})
    get_filename_component(HEADER_DIR ${HEADER_FILE} PATH)
    list(APPEND INCLUDE_DIRS ${HEADER_DIR})
endforeach()
list(REMOVE_DUPLICATES INCLUDE_DIRS)

#
# Link
# 

add_executable(${PROJECT_NAME} ${SRC})
target_include_directories(${PROJECT_NAME} PUBLIC ${INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} nlohmann_json::nlohmann_json)