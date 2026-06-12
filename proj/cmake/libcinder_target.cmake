cmake_minimum_required( VERSION 3.16 FATAL_ERROR )

set( _OUTPUT_DIRECTORY_BASE ${CINDER_PATH}/${CINDER_LIB_DIRECTORY} )

set_target_properties( cinder PROPERTIES 
    ARCHIVE_OUTPUT_DIRECTORY     "${_OUTPUT_DIRECTORY_BASE}/$<CONFIG>/${PLATFORM_TOOLSET}"
    LIBRARY_OUTPUT_DIRECTORY     "${_OUTPUT_DIRECTORY_BASE}/$<CONFIG>/${PLATFORM_TOOLSET}"
    STATIC_LIBRARY_FLAGS_DEBUG   "${CINDER_STATIC_LIBS_DEPENDS_DEBUG}"
    STATIC_LIBRARY_FLAGS_RELEASE "${CINDER_STATIC_LIBS_DEPENDS_RELEASE}"
)

# The type is based on the value of the BUILD_SHARED_LIBS variable.
# When OFF ( default value ) Cinder will be built as a static lib
# and when ON as a shared library.
# See https://cmake.org/cmake/help/v3.0/command/add_library.html for more info.

# DLL/Shared library support
if( BUILD_SHARED_LIBS )
	# CINDER_SHARED_BUILD - used when building the DLL (dllexport)
	target_compile_definitions( cinder PRIVATE CINDER_SHARED_BUILD )
	# CINDER_SHARED - propagates to consumers (dllimport)
	target_compile_definitions( cinder PUBLIC CINDER_SHARED )
endif()

# Visual Studio and Xcode generators adds a ${CMAKE_BUILD_TYPE} to the ARCHIVE 
# and LIBRARY directories. Override the directories so, ${CMAKE_BUILD_TYPE} doesn't double up.
if( CINDER_MSW )
	set( PLATFORM_TOOLSET "$(PlatformToolset)" )
	if( NOT ( "${CMAKE_GENERATOR}" MATCHES "Visual Studio.+" ) )
		set( PLATFORM_TOOLSET "v143" )
	endif()
endif()

# Enforce the minimum C++ standard Cinder requires.
if( CINDER_MSW AND MSVC )
    if( MSVC_VERSION LESS 1930 )
        message( FATAL_ERROR "Cinder requires Visual Studio 2022 (MSVC 19.30) or newer." )
    endif()
endif()

# Determine C++ standard for Cinder (default 20, allow user override)
if( CMAKE_CXX_STANDARD )
    set( CINDER_CXX_STANDARD ${CMAKE_CXX_STANDARD} )
else()
    set( CINDER_CXX_STANDARD 20 )
endif()

# Validate minimum
if( CINDER_CXX_STANDARD LESS 20 )
    message( FATAL_ERROR "Cinder requires C++20 or later. CMAKE_CXX_STANDARD is set to ${CINDER_CXX_STANDARD}" )
endif()

# Set C++ standard for cinder target
target_compile_features( cinder PUBLIC cxx_std_${CINDER_CXX_STANDARD} )

# Determine CXX_EXTENSIONS: default OFF (prevents "namespace linux" issue)
# Only enable if user explicitly sets CMAKE_CXX_EXTENSIONS=ON
if( DEFINED CMAKE_CXX_EXTENSIONS )
    set( CINDER_CXX_EXTENSIONS ${CMAKE_CXX_EXTENSIONS} )
else()
    set( CINDER_CXX_EXTENSIONS OFF )
endif()

set_target_properties( cinder PROPERTIES
    CXX_STANDARD ${CINDER_CXX_STANDARD}
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ${CINDER_CXX_EXTENSIONS}
)

# This file will contain all dependencies, includes, definition, compiler flags and so on..
export( TARGETS cinder FILE ${PROJECT_BINARY_DIR}/${CINDER_LIB_DIRECTORY}/cinderTargets.cmake )

# And this command will generate a file on the ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
# that applications have to pull in order to link successfully with Cinder and its dependencies.
# This specific cinderConfig.cmake file will just hold a path to the above mention
# cinderTargets.cmake file which holds the actual info.
# CINDER_CXX_STANDARD and CINDER_CXX_EXTENSIONS will be substituted into the template
configure_file( ${CMAKE_CURRENT_LIST_DIR}/modules/cinderConfig.buildtree.cmake.in
    ${_OUTPUT_DIRECTORY_BASE}cinderConfig.cmake
)
