#
# This file will be included by cmake/share/Headers.cmake
#
# cmake/reflect/_Headers.cmake is generated by `mulle-sde reflect`.
# Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# contents are derived from the file locations

set( INCLUDE_DIRS
src
src/reflect
)

#
# contents selected with patternfile ??-header--private-generated-headers
#
set( PRIVATE_GENERATED_HEADERS
src/reflect/_MulleObjCInetFoundation-import-private.h
src/reflect/_MulleObjCInetFoundation-include-private.h
)

#
# contents selected with patternfile ??-header--private-generic-headers
#
set( PRIVATE_GENERIC_HEADERS
src/import-private.h
src/include-private.h
)

#
# contents selected with patternfile ??-header--public-generated-headers
#
set( PUBLIC_GENERATED_HEADERS
src/reflect/_MulleObjCInetFoundation-export.h
src/reflect/_MulleObjCInetFoundation-import.h
src/reflect/_MulleObjCInetFoundation-include.h
src/reflect/_MulleObjCInetFoundation-provide.h
)

#
# contents selected with patternfile ??-header--public-generic-headers
#
set( PUBLIC_GENERIC_HEADERS
src/import.h
src/include.h
)

#
# contents selected with patternfile ??-header--public-headers
#
set( PUBLIC_HEADERS
src/MulleObjCInetFoundation.h
src/MulleObjCLoader+MulleObjCInetFoundation.h
src/NSCharacterSet+MulleURL.h
src/NSHost.h
src/NSMutableCharacterSet+MulleURL.h
src/NSString+MulleURL.h
src/NSURL.h
)

