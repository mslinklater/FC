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
//#import <UIKit/UIKit.h>
#import "FCProtocols.h"
#import "FCActor.h"

@class FCResource;

@interface FCActorSystem : NSObject <FCGameObjectUpdate, FCGameObjectRender> {
	NSMutableArray* _allActorsArray;
	NSMutableArray* _updateActorsArray;
	NSMutableArray* _renderActorsArray;
	NSMutableArray* _tapGestureActorsArray;
	NSMutableArray* _deleteList;
	
	NSMutableDictionary* _classArraysDictionary;
	NSMutableDictionary* _actorIdDictionary;
	NSMutableDictionary* _actorNameDictionary;
	// actor name dict
}
@property(nonatomic, strong) NSMutableArray* allActorsArray;
@property(nonatomic, strong) NSMutableArray* updateActorsArray;
@property(nonatomic, strong) NSMutableArray* renderActorsArray;
@property(nonatomic, strong) NSMutableArray* tapGestureActorsArray;
@property(nonatomic, strong) NSMutableArray* deleteList;
@property(nonatomic, strong) NSMutableDictionary* classArraysDictionary;
@property(nonatomic, strong) NSMutableDictionary* actorIdDictionary;
@property(nonatomic, strong) NSMutableDictionary* actorNameDictionary;

+(FCActorSystem*)instance;

-(id)init;
-(id)actorOfClass:(Class)actorClass;
-(id)actorWithId:(NSString*)Id;
-(void)addToDeleteArray:(FCActor*)actor;
-(void)removeActor:(FCActor*)actor;
-(void)removeAllActors;
-(void)reset;

-(NSArray*)getActorsOfClass:(NSString*)actorClass;

-(FCActor*)actorAtPosition:(FC::Vector2f)pos;

// new stuff

-(NSArray*)createActorsOfClass:(NSString*)actorClass 
				  withResource:(FCResource*)res
						 named:(NSString*)name;

@end


