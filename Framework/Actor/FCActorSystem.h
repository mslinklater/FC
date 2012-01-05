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

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FCProtocols.h"
#import "FCActor.h"

@class FCResource;

@interface FCActorSystem : NSObject <FCGameObjectUpdate, FCGameObjectLifetime, FCGameObjectRender> {
	NSMutableArray *mAllActorsArray;
	NSMutableArray *mUpdateActorsArray;
	NSMutableArray *mRenderActorsArray;
	NSMutableArray *mTapGestureActorsArray;
	NSMutableArray *mDeleteList;
	
	NSMutableDictionary *mClassArraysDictionary;
	NSMutableDictionary *mActorIdDictionary;
}
+(FCActorSystem*)instance;

-(id)init;
-(id)actorOfClass:(Class)actorClass;
-(NSMutableSet*)actorsWithId:(NSString*)Id;
-(void)addToDeleteArray:(id)actor;
-(void)removeActor:(id)actor;
-(void)removeAllActors;

-(NSArray*)getUpdateActors;
-(NSArray*)getActorsOfClass:(NSString*)actorClass;

-(FCActor*)actorAtPosition:(FC::Vector2f)pos;

// new stuff

-(NSArray*)createActorsOfClass:(NSString*)actorClass withResource:(FCResource*)res;

@end

#endif // TARGET_OS_IPHONE
