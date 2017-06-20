cmake_minimum_required (VERSION 3.0)

project (MulleObjCInetFoundation)


set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/mulle-configuration/cmake)
message( STATUS "CMAKE_MODULE_PATH is ${CMAKE_MODULE_PATH}")
message( STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")

set( MULLE_LANGUAGE "ObjC")

if( "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  include( Debug)
else()
  include( Release)
endif()

include( CMakeSourcesAndHeaders.txt)
include( CMakeDependencies.txt)


add_library( MulleObjCInetFoundation STATIC
${SOURCES}
${PUBLIC_HEADERS}
${PRIVATE_HEADERS}
CMakeDependencies.txt
CMakeSourcesAndHeaders.txt
)

target_link_libraries( MulleObjCInetFoundation
)


add_library( MulleObjCInetFoundationStandalone SHARED
src/MulleObjCInetFoundationStandalone.m
${PUBLIC_HEADERS}
)

add_dependencies( MulleObjCInetFoundationStandalone MulleObjCInetFoundation)

target_link_libraries( MulleObjCInetFoundationStandalone
${BEGIN_ALL_LOAD}
MulleObjCInetFoundation
${C_DEPENDENCY_LIBRARIES}
${OBJC_DEPENDENCY_LIBRARIES}
${END_ALL_LOAD}
${OS_SPECIFIC_LIBRARIES}
)

message( STATUS "OBJC_DEPENDENCY_NAMES is ${OBJC_DEPENDENCY_NAMES}")

# runs in build dir
add_custom_command( TARGET MulleObjCInetFoundationStandalone
   POST_BUILD
   COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-make-dependencies-inc -v -o ${CMAKE_SOURCE_DIR}/src/dependencies.inc MulleObjCInetFoundation ${OBJC_DEPENDENCY_NAMES}
)

set( PUBLIC_HEADERS
${PUBLIC_HEADERS}
"CMakeDependencies.txt"
"src/dependencies.inc"
)

install( TARGETS MulleObjCInetFoundation MulleObjCInetFoundationStandalone DESTINATION "lib")
install( FILES ${PUBLIC_HEADERS} DESTINATION "include/MulleObjCInetFoundation")
install( FILES ${PRIVATE_HEADERS} DESTINATION "include/MulleObjCInetFoundation/private")
