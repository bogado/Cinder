/*
 Copyright (c) 2012, The Cinder Project, All rights reserved.

 This code is intended for use with the Cinder C++ library: http://libcinder.org

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that
 the following conditions are met:

	* Redistributions of source code must retain the above copyright notice, this list of conditions and
	   the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
	   the following disclaimer in the documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/

#pragma once

#include "cinder/app/linux/AppLinux.h"
#include "cinder/app/glfw/AppImplGlfw.h"

#if defined( CINDER_LINUX_EGL_ONLY )
	#include "EGL/egl.h"
#else
	#include "glad/glad.h"
	#include "glfw/glfw3.h"
#endif


#include <list>

namespace cinder { namespace app {

class WindowImplLinux;

class AppImplLinux : public AppImplGlfw {
 public:

	AppImplLinux( AppLinux *aApp, const AppLinux::Settings &settings );
	~AppImplLinux() override;

	AppLinux					*getApp();

 protected:
	WindowRef					createWindow( Window::Format format );

private:
	AppLinux					*app() { return static_cast<AppLinux*>(getApp()); }
	void						run();

	void						registerWindowEvents( WindowImplLinux* window );
	void						unregisterWindowEvents( WindowImplLinux* window );

	friend class WindowImplLinux;
    friend class AppImplLinux;
    friend class AppImplLinuxGlfw;
#if ! defined( CINDER_LINUX_EGL_ONLY )
	friend class GlfwCallbacks;
    friend class linux::GlfwCallbacks;
#endif
};

}} // namespace cinder::app
