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

/*
 
 TODO:

 fov
 frustum translation
 nearclip
 farclip
 
 _gameView.fov = 0.4f;
 _gameView.frustumTranslation = FC::Vector3f( 0, 0, -18.0f );
 _gameView.nearClip = 1.0f;
 _gameView.farClip = 100.0f;
 
 */

#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif

//#if defined (FC_LUA)
//#import "FCLuaClass.h"
//#endif

@protocol FCManagedView <NSObject>
-(void)setManagedViewName:(NSString*)name;
-(NSString*)managedViewName;
@end

class FCLuaVM;

#if defined (FC_LUA)
//@interface FCViewManager : NSObject <FCLuaClass> {
@interface FCViewManager : NSObject {
#else
	@interface FCViewManager : NSObject {
#endif
@private
	NSMutableDictionary* _viewDictionary;
	NSMutableDictionary* _groupDictionary;
		
#if TARGET_OS_IPHONE
	UIView* _rootView;
#else
	NSView* _rootView;
#endif
}
@property(nonatomic, strong) NSMutableDictionary* viewDictionary;
@property(nonatomic, strong) NSMutableDictionary* groupDictionary;
	
#if TARGET_OS_IPHONE
@property(nonatomic, strong) UIView* rootView;
#else
@property(nonatomic, strong) NSView* rootView;
#endif

+(FCViewManager*)instance;
	
#if defined (FC_LUA)
+(void)registerLuaFunctions:(FCLuaVM *)lua;
#endif

-(void)printViews;
	
-(void)createView:(NSString*)name asClass:(NSString*)className withParent:(NSString*)parentView;
-(void)destroyView:(NSString*)name;
	
#if TARGET_OS_IPHONE
-(void)add:(UIView*)view as:(NSString*)name;
#else
-(void)add:(NSView*)view as:(NSString*)name;
#endif
	
-(UIView*)viewNamed:(NSString*)name;
	
-(void)remove:(NSString*)name;

-(void)createGroup:(NSString*)groupName;
-(void)removeGroup:(NSString*)groupName;
-(void)add:(NSString*)name toGroup:(NSString*)groupName;
-(void)remove:(NSString*)name fromGroup:(NSString*)groupName;

-(void)sendViewToBack:(NSString*)name;
-(void)sendViewToFront:(NSString*)name;
-(void)makeView:(NSString*)name inFrontOf:(NSString*)relativeName;
-(void)makeView:(NSString*)name behind:(NSString*)relativeName;

#if TARGET_OS_IPHONE
-(CGRect)rectForRect:(CGRect)rect containedInView:(UIView*)view;
#else
-(CGRect)rectForRect:(CGRect)rect containedInView:(NSView*)view;
#endif

// get these working with groups
-(void)setView:(NSString*)viewName text:(NSString*)text;
#if TARGET_OS_IPHONE
-(void)setView:(NSString*)viewName textColor:(UIColor*)color;
#else
-(void)setView:(NSString*)viewName textColor:(NSColor*)color;
#endif
-(void)setView:(NSString*)viewName frame:(CGRect)frame over:(float)seconds;
-(CGRect)getViewFrame:(NSString*)viewName;
-(void)setView:(NSString*)viewName alpha:(float)alpha over:(float)seconds;
-(void)setView:(NSString*)viewName onSelectLuaFunc:(NSString*)funcName;
-(void)setView:(NSString *)viewName image:(NSString*)imageName;
-(void)setView:(NSString *)viewName url:(NSString*)url;
	
-(void)setView:(NSString *)viewName property:(NSString*)property to:(id)value;
@end


