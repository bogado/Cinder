cmake_minimum_required( VERSION 3.16 FATAL_ERROR )

ci_log_v( "Building Cinder for ${CINDER_TARGET}" )

set( CINDER_SRC_DIR 	"${CINDER_PATH}/src" )
set( CINDER_INC_DIR		"${CINDER_PATH}/include" )

if( NOT CINDER_MSW )
    target_compile_options(cinder
        PRIVATE -Wfatal-errors 
	    PUBLIC -DHAVE_UNISTD_H
    )
endif()

list( APPEND CMAKE_MODULE_PATH ${CINDER_CMAKE_DIR} ${CMAKE_CURRENT_LIST_DIR}/modules )

target_include_directories(cinder BEFORE INTERFACE
    ${CINDER_INC_DIR}
)

if (NOT CINDER_IMPORTED)
    target_include_directories(cinder AFTER PRIVATE 
        ${CINDER_INC_DIR}
        ${CINDER_INC_DIR}/jsoncpp
        ${CINDER_INC_DIR}/tinyexr
        ${CINDER_SRC_DIR}/linebreak
        ${CINDER_INC_DIR}/oggvorbis
        ${CINDER_SRC_DIR}/oggvorbis/vorbis
        ${CINDER_SRC_DIR}/r8brain
    )

    # *_PRIVATE includes for imgui taking into account a potential custom path
    if( CINDER_IMGUI_DIR )
        target_include_directories(cinder AFTER PUBLIC
            ${CINDER_IMGUI_DIR}
            ${CINDER_IMGUI_DIR}/backends
            ${CINDER_IMGUI_DIR}/misc/freetype
            ${CINDER_IMGUI_DIR}/misc/cpp
        )

        target_compile_definitions(cinder PUBLIC CINDER_IMGUI_EXTERNAL )
    else()
        target_include_directories(cinder AFTER PUBLIC
            ${CINDER_INC_DIR}/imgui
        )
    endif()

    if( CINDER_HEADLESS_GL_EGL )
        target_include_directories(cinder PRIVATE ${CINDER_INC_DIR}/EGL-Registry )
    endif()

    # find cross-platform packages

    find_package( PNG )

    target_link_libraries(cinder PUBLIC PNG::PNG)

    if( CINDER_FREETYPE_USE_SYSTEM )
        #	TODO: finish this, not sure what to do about library linking
        find_package( Freetype 2.0 REQUIRED )
        target_link_libraries(cinder PUBLIC Freetype::Freetype )
    else()
        # use freetype copy that ships with cinder
        ci_log_v( "using freetype copy that ships with cinder" )
        target_include_directories(cinder PRIVATE ${CINDER_INC_DIR}/freetype)
        target_compile_definitions(cinder PRIVATE
            FT2_BUILD_LIBRARY
            FT_DEBUG_LEVEL_TRACE
        )
    endif()
endif()
