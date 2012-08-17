/*
 Copyright (C) 2011-2012 by Martin Linklater
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#ifndef CR2_FCUI_platform_h
#define CR2_FCUI_platform_h

extern void plt_FCViewManager_SetScreenAspectRatio( float w, float h );
extern void plt_FCViewManager_SetViewText( const std::string& viewName, std::string text );
extern void plt_FCViewManager_SetViewTextColor( const std::string& viewName, FCColor4f color );
extern FCRect plt_FCViewManager_ViewFrame( const std::string& viewName );
extern FCRect plt_FCViewManager_FullFrame();
extern void plt_FCViewManager_SetViewFrame( const std::string& viewName, const FCRect& rect, float seconds );
extern void plt_FCViewManager_SetViewAlpha( const std::string& viewName, float alpha, float seconds );
extern void plt_FCViewManager_SetViewOnSelectLuaFunction( const std::string& viewName, const std::string& func );
extern void plt_FCViewManager_SetViewImage( const std::string& viewName, const std::string& image );
extern void plt_FCViewManager_SetViewURL( const std::string& viewName, const std::string& url );
extern void plt_FCViewManager_SetViewBackgroundColor( const std::string& viewName, const FCColor4f& color );
extern void plt_FCViewManager_CreateView( const std::string& viewName, const std::string& className, const std::string& parent );
extern void plt_FCViewManager_DestroyView( const std::string& viewName );
extern void plt_FCViewManager_SetViewPropertyInt( const std::string& viewName, const std::string& property, int32_t value );
extern void plt_FCViewManager_SetViewPropertyString( const std::string& viewName, const std::string& property, const std::string& value );

extern void plt_FCViewManager_SendViewToFront( const std::string& viewName );
extern void plt_FCViewManager_SendViewToBack( const std::string& viewName );
extern bool plt_FCViewManager_ViewExists( const std::string& viewName );

#endif
