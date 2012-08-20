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
extern void plt_FCViewManager_SetViewText( const char* viewName, const char* text );
extern void plt_FCViewManager_SetViewTextColor( const char* viewName, FCColor4f color );
extern FCRect plt_FCViewManager_ViewFrame( const char* viewName );
extern FCRect plt_FCViewManager_FullFrame();
extern void plt_FCViewManager_SetViewFrame( const char* viewName, const FCRect& rect, float seconds );
extern void plt_FCViewManager_SetViewAlpha( const char* viewName, float alpha, float seconds );
extern void plt_FCViewManager_SetViewOnSelectLuaFunction( const char* viewName, const char* func );
extern void plt_FCViewManager_SetViewImage( const char* viewName, const char* image );
extern void plt_FCViewManager_SetViewURL( const char* viewName, const char* url );
extern void plt_FCViewManager_SetViewBackgroundColor( const char* viewName, const FCColor4f& color );
extern void plt_FCViewManager_CreateView( const char* viewName, const char* className, const char* parent );
extern void plt_FCViewManager_DestroyView( const char* viewName );
extern void plt_FCViewManager_SetViewPropertyInt( const char* viewName, const char* property, int32_t value );
extern void plt_FCViewManager_SetViewPropertyString( const char* viewName, const char* property, const char* value );

extern void plt_FCViewManager_SendViewToFront( const char* viewName );
extern void plt_FCViewManager_SendViewToBack( const char* viewName );
extern bool plt_FCViewManager_ViewExists( const char* viewName );

#endif
