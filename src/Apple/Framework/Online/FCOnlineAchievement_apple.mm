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


#import "FCOnlineAchievement_apple.h"
#import "FCCore_apple.h"

#include "Shared/FCPlatformInterface.h"

static FCOnlineAchievement_apple* s_pInstance = 0;

void plt_FCOnlineAchievement_Init()
{
	[FCOnlineAchievement_apple instance];
}

void plt_FCOnlineAchievement_RefreshFromServer( )
{
	[s_pInstance refreshFromServer];
}

void plt_FCOnlineAchievement_UpdateProgress( const char* name, float progress )
{
	[s_pInstance reportAchievementName:[NSString stringWithUTF8String:name] amount:progress];
}

void plt_FCOnlineAchievement_ReportUnreported()
{
	[s_pInstance reportUnreportedAchievements];
}

void plt_FCOnlineAchievement_ClearAll()
{
	[s_pInstance clearAll];
}

@implementation FCOnlineAchievement_apple

+(FCOnlineAchievement_apple*)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCOnlineAchievement_apple alloc] init];
	}
	return s_pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		
		[self authenticateLocalPlayer];
		
		// deserialise unreported achievements
		
		_unreportedAchievements = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filename]];
		if (_unreportedAchievements == nil) {
			_unreportedAchievements = [NSMutableArray array];
		}

		[self reportUnreportedAchievements];
	}
	return self;
}

-(NSString*)filename
{
	NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString* documentDirectory = [documentDirectories objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:@"achievements"];
}

-(void)authenticateLocalPlayer
{
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error)
	{
        if (localPlayer.isAuthenticated)
        {
            _localPlayer = localPlayer;
        } else {
            _localPlayer = nil;
        }
    }];
}

-(void)reportAchievementName:(NSString *)name amount:(float)amount
{
	BOOL isNew = YES;
	
	for (GKAchievement* achievement in _unreportedAchievements) {
		if( [achievement.identifier isEqualToString:name] )
		{
			isNew = NO;
			if (achievement.percentComplete < amount) {
				achievement.percentComplete = amount * 100.0f;
			}
		}
	}

	if (isNew) {
		GKAchievement* achievement = [[GKAchievement alloc] initWithIdentifier:name];
		achievement.percentComplete = amount * 100.0f;
		achievement.showsCompletionBanner = YES;
		[_unreportedAchievements addObject:achievement];
	}
	
	[self reportUnreportedAchievements];
}

-(void)reportUnreportedAchievements
{
	if (_localPlayer == nil) {
		[self authenticateLocalPlayer];
		return;
	}

	NSMutableArray* unreported = [NSMutableArray array];

	// try

	for( GKAchievement* achievement in _unreportedAchievements )
	{
		[achievement reportAchievementWithCompletionHandler:^(NSError *error)
		 {
			 if (error != nil)
			 {
				 [unreported addObject:achievement];
			 }
		 }];
	}

	_unreportedAchievements = unreported;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		[NSKeyedArchiver archiveRootObject:_unreportedAchievements toFile:[self filename]];
	});
}

-(void)refreshFromServer
{
	if (_localPlayer == nil) {
		return;
	}
	
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error != nil)
        {
            // handle errors
        }
        if (achievements != nil)
        {
			for( GKAchievement* achievement in achievements )
			{
//				fc_FCOnlineAchievement_ServerProgress( [achievement.identifier UTF8String], achievement.percentComplete * 0.01f );
			}
        }
	}];
}

-(void)clearAll
{
	if (_localPlayer == nil) {
		[self authenticateLocalPlayer];
		return;
	}
	
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
	 {
		 if (error != nil)
		 {
		 }
	 }];
}

@end
