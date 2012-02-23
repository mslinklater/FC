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

#if defined(FC_GRAPHICS)

#import <Foundation/Foundation.h>
#import "Maths/FCMaths.h"
#import "Core/FCTypes.h"

@class FCResource;

@interface FCModel : NSObject {	
	NSMutableArray* _meshes;
	FC::Vector3f _position;
	float _rotation;
}

@property(nonatomic, strong) NSMutableArray* meshes;
@property(nonatomic) FC::Vector3f position;
@property(nonatomic) float rotation;

-(void)render;

-(id)initWithModel:(NSDictionary*)modelDict resource:(FCResource*)res;
-(id)initWithPhysicsBody:(NSDictionary*)bodyDict color:(UIColor*)color;// actorXOffset:(float)actorX actorYOffset:(float)actorY;
-(void)setDebugMeshColor:(FC::Color4f)color;
@end

#endif // defined(FC_GRAPHICS)
