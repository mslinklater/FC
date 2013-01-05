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

#import <Foundation/Foundation.h>

@protocol FCManagedView_apple <NSObject>
-(void)setManagedViewName:(NSString*)name;
-(NSString*)managedViewName;
@end

class FCLuaVM;

@interface FCViewManager_apple : NSObject {
@private
	NSMutableDictionary* _viewDictionary;
	UIView* _rootView;
}
@property(nonatomic, strong) NSMutableDictionary* viewDictionary;

@property(nonatomic, strong) UIView* rootView;

+(FCViewManager_apple*)instance;

-(void)printViews;

-(void)createView:(NSString*)name asClass:(NSString*)className withParent:(NSString*)parentView;
-(void)destroyView:(NSString*)name;
-(void)shrinkFontToFit:(NSString*)name;
-(void)add:(UIView*)view as:(NSString*)name;

-(UIView*)viewNamed:(NSString*)name;

-(void)remove:(NSString*)name;

-(void)moveViewToBack:(NSString*)name;
-(void)moveViewToFront:(NSString*)name;
-(void)makeView:(NSString*)name inFrontOf:(NSString*)relativeName;
-(void)makeView:(NSString*)name behind:(NSString*)relativeName;

-(void)setScreenAspectRatioWidth:(float)w height:(float)h;

-(CGRect)rectForRect:(CGRect)rect containedInView:(UIView*)view;

-(void)setView:(NSString*)viewName backgroundColor:(UIColor*)color;
-(void)setView:(NSString*)viewName text:(NSString*)text;
-(void)setView:(NSString*)viewName textColor:(UIColor*)color;
-(void)setView:(NSString*)viewName frame:(CGRect)frame over:(float)seconds;
-(CGRect)getViewFrame:(NSString*)viewName;
-(void)setView:(NSString*)viewName alpha:(float)alpha over:(float)seconds;
-(void)setView:(NSString*)viewName onSelectLuaFunc:(NSString*)funcName;
-(void)setView:(NSString *)viewName image:(NSString*)imageName;
-(void)setView:(NSString *)viewName url:(NSString*)url;

-(void)setView:(NSString *)viewName property:(NSString*)property to:(id)value;
@end
