cmake_minimum_required (VERSION 3.0)

project( MulleObjCInetFoundation C)


set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/mulle-configuration/cmake)
message( STATUS "CMAKE_MODULE_PATH is ${CMAKE_MODULE_PATH}")
message( STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")

set( MULLE_LANGUAGE "ObjC")

if( "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  include( Debug)
else()
  include( Release)
endif()

set( MULLE_OBJC_INET_FOUNDATION_LIBRARY ON)

include( CMakeDependencies.txt)
include( CMakeSourcesAndHeaders.txt)

include_directories( ${INCLUDE_DIRS})


set( PUBLIC_HEADERS
${PUBLIC_HEADERS}
"CMakeDependencies.txt"
"src/dependencies.inc"
)

add_library( MulleObjCInetFoundation STATIC
${SOURCES}
${PUBLIC_HEADERS}
${PRIVATE_HEADERS}
CMakeSourcesAndHeaders.txt
)

set( STANDALONE_BASE_NAME "MulleObjCInetFoundation")
set( STANDALONE_NAME "MulleObjCInetFoundationStandalone")
set( STANDALONE_DEFINITIONS ${MULLE_OBJC_INET_FOUNDATION_DEFINITIONS})
set( STANDALONE_ALL_LOAD_LIBRARIES
    $<TARGET_FILE:${STANDALONE_BASE_NAME}>
    ${OBJC_DEPENDENCY_LIBRARIES}
    ${OBJC_STARTUP_LIBRARY}
    ${C_DEPENDENCY_LIBRARIES}
)
include( Standalone)

install( TARGETS MulleObjCInetFoundation MulleObjCInetFoundationStandalone DESTINATION "lib")
install( FILES ${PUBLIC_HEADERS} DESTINATION "include/MulleObjCInetFoundation")
install( FILES ${PRIVATE_HEADERS} DESTINATION "include/MulleObjCInetFoundation/private")

include( MulleTest)
