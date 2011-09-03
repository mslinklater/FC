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

#import "FCMaths.h"

@class FCResource;

@protocol FCActorBase

-(id)initWithDictionary:(NSDictionary*)dictionary body:(NSDictionary*)bodyDict model:(NSDictionary*)modelDict resource:(FCResource*)res;
-(void)dealloc;

@optional
-(void)update:(float)gameTime;
-(void)render;
-(BOOL)needsUpdate;
-(BOOL)needsRender;
-(BOOL)respondsToTapGesture;
-(float)radius;
-(BOOL)posWithinBounds:(FC::Vector2f)pos;

@end

@protocol FCGameObjectLifetime
-(void)reset;
-(void)destroy;
@end

@protocol FCGameObjectUpdate
-(void)update:(float)realTime gameTime:(float)gameTime;
@end

@protocol FCGameObjectRender
-(NSArray*)renderGather;
@end

