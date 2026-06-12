# Copyright (c) 2013 Martin Felis <martin@fysx.org>
# License: Public Domain (Unlicense: http://unlicense.org/)
#
# Try to find MPG123. Sets the following variables:
#   MPG123_FOUND
#   MPG123_INCLUDE_DIR
#   MPG123_LIBRARY

set( MPG123_FOUND false )
find_package(PkgConfig REQUIRED)
pkg_check_modules(_pc_mpg123 libmpg123)

find_path( MPG123_INCLUDE_DIR NAMES "mpg123.h" HINTS ${_pc_mpg123_INCLUDEDIR} PATH_SUFFIXES include)
find_library( MPG123_LIBRARY  NAMES "mpg123" HINTS ${_pc_mpg123_LIBDIR} )

mark_as_advanced( MPG123_INCLUDE_DIR MPG123_LIBRARY )

if( MPG123_INCLUDE_DIR AND EXISTS "${MPG123_INCLUDE_DIR}/mpg123.h" )
    file( STRINGS "${MPG123_INCLUDE_DIR}/mpg123.h" MPG123_H
        REGEX "libmpg123: MPEG Audio Decoder library \\(version [^\"]*\\)$" )

    string( REGEX REPLACE "^.*\\(version ([0-9]+).*\\)$" "\\1" MPG123_VERSION_MAJOR "${MPG123_H}" )
    string( REGEX REPLACE "^.*\\(version [0-9]+\\.([0-9]+).*\\)$" "\\1" MPG123_VERSION_MINOR  "${MPG123_H}" )
    string( REGEX REPLACE "^.*\\(version [0-9]+\\.[0-9]+\\.([0-9]+).*\\)$" "\\1" MPG123_VERSION_PATCH "${MPG123_H}" )
    set( MPG123_VERSION_STRING "${MPG123_VERSION_MAJOR}.${MPG123_VERSION_MINOR}.${MPG123_VERSION_PATCH}" )

    set( MPG123_MAJOR_VERSION "${MPG123_VERSION_MAJOR}" )
    set( MPG123_MINOR_VERSION "${MPG123_VERSION_MINOR}" )
    set( MPG123_PATCH_VERSION "${MPG123_VERSION_PATCH}" )
endif()

add_library(MPG123::mpg123 SHARED IMPORTED GLOBAL)
target_include_directories( MPG123::mpg123 INTERFACE "${MPG123_INCLUDE_DIR}")
set_target_properties( MPG123::mpg123 PROPERTIES IMPORTED_LOCATION "${MPG123_LIBRARY}")

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( 
	MPG123 
	REQUIRED_VARS MPG123_LIBRARY MPG123_INCLUDE_DIR 
	VERSION_VAR MPG123_VERSION_STRING
)

if( MPG123_FOUND )
	message( STATUS "  using MPG123 headers at: ${MPG123_INCLUDE_DIR}" )
endif()
