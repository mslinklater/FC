/*
 Copyright (C) 2011 by Martin Linklater
 
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

 textcolor
 backgroundcolor
 
 */

#import <Foundation/Foundation.h>
#import "FCLuaClass.h"

@protocol FCManagedView <NSObject>
-(void)setManagedViewName:(NSString*)name;
-(NSString*)managedViewName;
@end

@interface FCViewManager : NSObject <FCLuaClass> {
@private
	UIView* _rootView;
	NSMutableDictionary* _viewDictionary;
}
@property(nonatomic, strong) UIView* rootView;
@property(nonatomic, strong) NSMutableDictionary* viewDictionary;

+(FCViewManager*)instance;
+(void)registerLuaFunctions:(FCLuaVM *)lua;

-(void)add:(UIView*)view as:(NSString*)name;
-(void)createGroupWith:(NSArray*)names called:(NSString*)groupName;
-(void)remove:(NSString*)name;

-(void)setView:(NSString*)viewName text:(NSString*)text;
-(void)setView:(NSString*)viewName textColor:(UIColor*)color;
-(void)setView:(NSString*)viewName frame:(CGRect)frame over:(float)seconds;
-(void)setView:(NSString*)viewName alpha:(float)alpha over:(float)seconds;
-(void)setView:(NSString*)viewName onSelectLuaFunc:(NSString*)funcName;
@end

