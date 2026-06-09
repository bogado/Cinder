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
#include "cinder/app/glfw/WindowImplGlfw.h"
#include "cinder/app/Window.h"
#include "cinder/Display.h"
#include <cinder/app/glfw/AppImplGlfw.h>

#if defined( CINDER_LINUX_EGL_ONLY )
	#include "EGL/eglplatform.h"
#elif ! defined( CINDER_HEADLESS )
	#include "glad/glad.h"
	#include "glfw/glfw3.h"
	#include "glfw/glfw3native.h"
#endif

namespace cinder { namespace app {

class AppImplLinux;

class WindowImplLinux : public WindowImplGlfw {
public:

	WindowImplLinux( const Window::Format &format, WindowImplGlfw *sharedRendererWindow, AppImplLinux *appImpl );
	virtual ~WindowImplLinux();

	bool		isFullScreen() override { return mFullScreen; }
	void		setFullScreen( bool fullScreen, const app::FullScreenOptions &options ) override;
	ivec2		getSize() const override;
	void		setSize( const ivec2 &size ) override;
	ivec2		getPos() const override;
	void		setPos( const ivec2 &pos ) override;
	void		close() override;
	std::string	getTitle() const override { return mTitle; }
	void		setTitle( const std::string &title ) override;
	void		hide() override;
	void		show() override;
	bool		isHidden() const override { return false; }
	DisplayRef	getDisplay() const override { return mDisplay; }
	RendererRef	getRenderer() const override { return mRenderer; }
	const std::vector<TouchEvent::Touch>&	getActiveTouches() const override;

#if defined( CINDER_HEADLESS )
	void*	getNative() override;
	void*	getNative() const override;
#else
	GLFWwindow	*getNative() override { return mGlfwWindow; }
	GLFWwindow	*getNative() const override { return mGlfwWindow; }
#endif

	bool				isBorderless() const { return mBorderless; }
	void				setBorderless( bool borderless );
	bool				isAlwaysOnTop() const { return mAlwayOnTop; }
	void				setAlwaysOnTop( bool alwaysOnTop );

	AppImplGlfw*		getAppImpl() { return mAppImpl; }
	WindowRef			getWindow() { return mWindowRef; }

	void		keyDown( const KeyEvent &event ) override;
	void		draw() override;
	void		resize() override;


	void				hideCursor();
	void				showCursor();
	ivec2				getMousePos() const;

protected:
	WindowRef			mWindowRef;
	GLFWwindow			*mGlfwWindow = nullptr;

	std::string			mTitle;
	bool				mFullScreen = false;
	bool				mBorderless = false;
	bool				mAlwayOnTop = false;

	ivec2			mWindowedSize, mWindowedPos; // used to preserve info when toggling fullscreen

	DisplayRef			mDisplay;
	RendererRef			mRenderer;

	// Always empty for now
	std::vector<TouchEvent::Touch>	mActiveTouches;

	friend class AppImplLinux;
    friend class linux::GlfwCallbacks;
};

}} // namespace cinder::app
