//
//  FCApp.h
//
//  Created by Martin Linklater on 28/10/2011.
//  Copyright (c) 2011 CurlyRocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCLua.h"

@interface FCApp : NSObject
+(void)coldBoot;
+(void)warmBoot;
+(void)shutdown;
+(void)update;
+(void)startInternalUpdate;
+(void)stopInternalUpdate;

+(FCLuaVM*)lua;
@end
