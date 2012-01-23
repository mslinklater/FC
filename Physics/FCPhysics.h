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

#import "FCCore.h"

#import "FCPhysics2D.h"
#import "FCPhysics3D.h"
#import "FCPhysicsMaterial.h"

@interface FCPhysics : NSObject <FCGameObjectLifetime, FCGameObjectUpdate> {
	FCPhysics2D* _twoD;
	NSMutableDictionary* _materials;
}
@property(strong, nonatomic, readonly) FCPhysics2D* twoD;
//@property(weak, nonatomic, readonly) FCPhysics3D* threeD;
@property(nonatomic, strong) NSMutableDictionary* materials;

+(FCPhysics*)instance;

-(void)create2DComponent;
-(void)create3DComponent;

-(void)reset;
-(void)addMaterial:(FCPhysicsMaterial*)material;
@end

#endif // TARGET_OS_IPHONE
