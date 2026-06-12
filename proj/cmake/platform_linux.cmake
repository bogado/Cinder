cmake_minimum_required( VERSION 3.16 FATAL_ERROR )

set( CMAKE_VERBOSE_MAKEFILE ON )

set( CINDER_PLATFORM "Posix" )

# Note: SRC_SET_GLFW, SRC_SET_GLFW_X11 are now defined in libcinder_source_files.cmake

# Linux-specific app files (not GLFW-specific)
list( APPEND SRC_SET_CINDER_APP_LINUX
	${CINDER_SRC_DIR}/cinder/app/linux/PlatformLinux.cpp
)

if( NOT CINDER_DISABLE_AUDIO )
	list( APPEND SRC_SET_CINDER_AUDIO_LINUX
	#	${CINDER_SRC_DIR}/cinder/audio/linux/ContextJack.cpp
		${CINDER_SRC_DIR}/cinder/audio/linux/ContextPulseAudio.cpp
	#	${CINDER_SRC_DIR}/cinder/audio/linux/DeviceManagerJack.cpp
		${CINDER_SRC_DIR}/cinder/audio/linux/DeviceManagerPulseAudio.cpp
		${CINDER_SRC_DIR}/cinder/audio/linux/FileAudioLoader.cpp
	)

	list( APPEND SRC_SET_CINDER_AUDIO_DSP
		${CINDER_SRC_DIR}/cinder/audio/dsp/ooura/fftsg.cpp
		${CINDER_SRC_DIR}/cinder/audio/dsp/ConverterR8brain.cpp
	)
endif()

if( NOT CINDER_DISABLE_VIDEO )
	list( APPEND SRC_SET_CINDER_VIDEO_LINUX
		${CINDER_SRC_DIR}/cinder/CaptureImplGStreamer.cpp
		${CINDER_SRC_DIR}/cinder/linux/GstPlayer.cpp
		${CINDER_SRC_DIR}/cinder/linux/Movie.cpp
	)
endif()

# Curl
list( APPEND SRC_SET_CINDER_LINUX ${CINDER_SRC_DIR}/cinder/UrlImplCurl.cpp )

# Relevant source files depending on target GL and if we running headless.
if( NOT CINDER_HEADLESS ) # Desktop ogl, es2, es3, RPi with GLFW
	message( STATUS "Using GLFW backend for Linux" )

	# Define CINDER_GLFW preprocessor macro
    target_compile_options( cinder PUBLIC -DCINDER_GLFW )
    target_compile_options( cinder PUBLIC -D_GLFW_X11 )

	if( CINDER_GL_ES )
		list( APPEND SRC_SET_CINDER_LINUX
			${CINDER_SRC_DIR}/glad/glad_es.c
		)
	else()
		list( APPEND SRC_SET_CINDER_LINUX
			${CINDER_SRC_DIR}/glad/glad_glx.c
		)
	endif()

	# Add GLFW library sources (core + X11 backend)
	list( APPEND SRC_SET_CINDER_LINUX
		${SRC_SET_GLFW}
		${SRC_SET_GLFW_X11}
	)

	# Add GLFW app implementation (from new glfw/ directory)
	list( APPEND SRC_SET_CINDER_APP_LINUX
        ${CINDER_SRC_DIR}/cinder/app/linux/AppImplLinuxGlfw.cpp
		${CINDER_SRC_DIR}/cinder/app/linux/WindowImplLinuxGlfw.cpp
		${CINDER_SRC_DIR}/cinder/app/glfw/AppGlfw.cpp
		${CINDER_SRC_DIR}/cinder/app/glfw/AppImplGlfw.cpp
		${CINDER_SRC_DIR}/cinder/app/glfw/RendererGlGlfw.cpp
		${CINDER_SRC_DIR}/cinder/app/glfw/RendererImplGlfwGl.cpp
		${CINDER_SRC_DIR}/cinder/app/glfw/WindowImplGlfw.cpp
	)

	source_group( "cinder\\app\\glfw" FILES ${SRC_SET_APP_GLFW} )
	source_group( "thirdparty\\glfw" FILES ${SRC_SET_GLFW} ${SRC_SET_GLFW_X11} )
else() # Headless egl, osmesa
	list( APPEND SRC_SET_CINDER_LINUX
		${CINDER_SRC_DIR}/cinder/app/linux/AppImplLinuxHeadless.cpp
		${CINDER_SRC_DIR}/cinder/app/linux/RendererGlLinuxHeadless.cpp
		${CINDER_SRC_DIR}/cinder/app/linux/WindowImplLinuxHeadless.cpp
	)
	if( CINDER_GL_ES )
		list( APPEND SRC_SET_CINDER_LINUX
			${CINDER_SRC_DIR}/glad/glad_es.c
		)
	endif()
endif()

target_sources( cinder PRIVATE
	${SRC_SET_CINDER_LINUX}
	${SRC_SET_CINDER_APP_LINUX}
	${SRC_SET_CINDER_AUDIO_LINUX}
	${SRC_SET_CINDER_AUDIO_DSP}
	${SRC_SET_CINDER_VIDEO_LINUX}
)

# Relevant libs and include dirs depending on target platform and target GL.
if( CINDER_GL_CORE )
	if( NOT CINDER_HEADLESS_GL_OSMESA )
		find_package( OpenGL REQUIRED )
		list( APPEND CINDER_LIBS_DEPENDS ${OPENGL_LIBRARIES} )
		list( APPEND CINDER_INCLUDE_SYSTEM_PRIVATE ${OPENGL_INCLUDE_DIR} )
		find_package( X11 REQUIRED )
		list( APPEND CINDER_LIBS_DEPENDS ${X11_LIBRARIES} Xcursor Xinerama Xrandr Xi )
		list( APPEND CINDER_INCLUDE_SYSTEM_PRIVATE ${X11_INCLUDE_DIR} )
		if( CINDER_HEADLESS_GL_EGL ) # Headless through EGL
			list( APPEND CINDER_LIBS_DEPENDS EGL )
		endif()
	else()
		find_package( X11 REQUIRED )
		list( APPEND CINDER_LIBS_DEPENDS ${X11_LIBRARIES} Xcursor Xinerama Xrandr Xi )
		list( APPEND CINDER_INCLUDE_SYSTEM_PRIVATE ${X11_INCLUDE_DIR} )
		find_package( OSMesa REQUIRED )
		list( APPEND CINDER_LIBS_DEPENDS ${OSMesa_LIBRARIES} )
		list( APPEND CINDER_INCLUDE_SYSTEM_PRIVATE ${OSMesa_INCLUDE_DIRS} )
	endif()
elseif( CINDER_GL_ES )
	find_package( X11 REQUIRED )
	list( APPEND CINDER_LIBS_DEPENDS ${X11_LIBRARIES} Xcursor Xinerama Xrandr Xi )
	list( APPEND CINDER_INCLUDE_SYSTEM_PRIVATE ${X11_INCLUDE_DIR} )
	list( APPEND CINDER_LIBS_DEPENDS EGL GLESv2 )
endif()

# Common libs for Linux.
# ZLib
find_package( ZLIB REQUIRED )
target_link_libraries( cinder PRIVATE ZLIB::ZLIB )
# Curl
find_package( CURL REQUIRED )
target_link_libraries( cinder PRIVATE CURL::libcurl )
# FontConfig
find_package( FontConfig REQUIRED )
target_link_libraries( cinder PRIVATE FontConfig::fontconfig)
if( NOT CINDER_DISABLE_AUDIO )
	# PulseAudio
	find_package( PulseAudio REQUIRED )
    target_link_libraries( cinder PRIVATE      ${PULSEAUDIO_LIBRARY} )
    target_include_directories( cinder PRIVATE ${PULSEAUDIO_INCLUDE_DIR} )
	# mpg123
	find_package( MPG123 REQUIRED )
    target_link_libraries( cinder PRIVATE MPG123::mpg123 )
	# sndfile
	find_package( SNDFILE REQUIRED )
	target_link_libraries( cinder PRIVATE      ${SNDFILE_LIBRARY} )
	target_include_directories( cinder PRIVATE ${SNDFILE_INCLUDE_DIR} )
endif()
# GStreamer and its dependencies.
if( NOT CINDER_DISABLE_VIDEO )
	# Glib
	find_package( Glib REQUIRED COMPONENTS gobject )
    target_link_libraries( cinder PRIVATE Glib::glib Glib::gobject )
	# GStreamer
    find_package( GStreamer COMPONENTS base app video gl)
    target_link_libraries( cinder PRIVATE
        GStreamer::gstreamer
        GStreamer::base
        GStreamer::app
        GStreamer::video
        GStreamer::gl
	)
endif()

find_package(Threads REQUIRED)
target_link_libraries( cinder PRIVATE dl Threads::Threads)

source_group( "cinder\\linux"			FILES ${SRC_SET_CINDER_LINUX} )
source_group( "cinder\\app\\linux"		FILES ${SRC_SET_CINDER_APP_LINUX} )
target_sources(cinder PRIVATE ${SRC_SET_CINDER_LINUX} ${SRC_SET_CINDER_APP_LINUX})

target_include_directories( cinder PUBLIC
	${CINDER_INC_DIR}/glfw
)

# Cinder GL defines depending on target GL.
if( CINDER_GL_CORE )
    target_compile_options( cinder PUBLIC "-DCINDER_GL_CORE" )
elseif( CINDER_GL_ES )
    target_compile_options( cinder PUBLIC "-DCINDER_GL_ES" )
	
	if( CINDER_GL_ES_2 )
        target_compile_options( cinder PUBLIC "-DCINDER_GL_ES_2" )
	elseif( CINDER_GL_ES_3 )
		target_compile_options( cinder PUBLIC "-DCINDER_GL_ES_3" )
	elseif( CINDER_GL_ES_3_1 )
		target_compile_options( cinder PUBLIC "-DCINDER_GL_ES_3_1" )
	elseif( CINDER_GL_ES_3_2 )
		target_compile_options( cinder PUBLIC "-DCINDER_GL_ES_3_2" )
	elseif( CINDER_GL_ES_3_RPI )
		target_compile_options( cinder PUBLIC "-DCINDER_GL_ES_3" "-DCINDER_GL_ES_3_RPI" )
	endif()
endif()

# Set appropriate defines when running headless.
if( CINDER_HEADLESS )
	if( CINDER_HEADLESS_GL_EGL )
        target_compile_options( cinder PUBLIC "-DCINDER_LINUX_EGL_ONLY -DCINDER_HEADLESS -DCINDER_HEADLESS_GL_EGL" )
	elseif( CINDER_HEADLESS_GL_OSMESA )
        target_compile_options( cinder PUBLIC "-DCINDER_HEADLESS -DCINDER_HEADLESS_GL_OSMESA" )
	endif()
else() # If not headless we need X.
	list( APPEND GLFW_FLAGS "-D_GLFW_X11" )
endif()

target_compile_options( cinder PUBLIC "-D_UNIX" ${GLFW_FLAGS}  )
