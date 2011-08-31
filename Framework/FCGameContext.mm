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

#if TARGET_OS_IPHONE

#import "GameKit/GameKit.h"

#import "FCGameContext.h"
#import "FCXMLData.h"
#import "FCUIManager.h"
#import "FCResourceManager.h"
#import "FCCaps.h"
#import "FCRenderer.h"
#import "FCActorSystem.h"
#import "FCPhysics.h"
#import "FCPersistentData.h"
#import "FCStats.h"
#import "FCCaps.h"
#import "FCUserDefaults.h"
#import "FCAnalytics.h"
#import "FCNotifications.h"

@implementation FCGameContext

@synthesize gameData = _gameData;
@synthesize state = _state;
@synthesize localPlayerGameCenterId = _localPlayerGameCenterID;
@synthesize gameRoot = _gameRoot;
@synthesize mainGameView = _mainGameView;

#pragma mark -
#pragma mark Caps Probing


-(void)probeCaps
{
}

#pragma mark - Detecting OS Features

-(void)localPlayerGameCenterIdChanged
{
	NSArray* statsArray = [[[FCGameContext instance] gameData] arrayForKeyPath:@"gamedata.stats.stat"];
	[[FCStats instance] prepareStatsFromArray:statsArray withPlayerId:self.localPlayerGameCenterId];

	[[NSNotificationCenter defaultCenter] postNotificationName:kFCNotificationPlayerIDChanged object:nil];
}

#pragma mark -
#pragma mark Lifespan

-(id)init
{
	self = [super init];
	if (self) 
	{
		// initialise core FC systems
		
		[[FCCaps instance] probeCaps];
		[[FCAnalytics instance] registerSystemValues];

		[FCUIManager instance];
		[FCResourceManager instance];
		_gameData = [[FCXMLData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gamedata" ofType:@"xml"]];
		[[FCUserDefaults instance] registerDefaults];
		_state = [[NSMutableDictionary alloc] init];
		[[FCRenderer instance] addToGatherList:[FCActorSystem instance]];
		[FCPhysics instance];
		NSArray* statsArray = [[[FCGameContext instance] gameData] arrayForKeyPath:@"gamedata.stats.stat"];
		[[FCStats instance] prepareStatsFromArray:statsArray withPlayerId:@"local"];

		// game center
		
		if ([[FCCaps instance] valueForKey:kFCCapsOSGameCenter] != kFCCapsNotPresent)
		{
			[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) 
			{
				if (error == nil)
				{
					self.localPlayerGameCenterId = [[GKLocalPlayer localPlayer] playerID];
					[[FCCaps instance] setGameCenterAvailable];
					[self localPlayerGameCenterIdChanged];
				}
				else
				{
					[[FCCaps instance] setGameCenterUnavailable];
					self.localPlayerGameCenterId = @"local";
				}
			}];
		}
		else
		{
			self.localPlayerGameCenterId = @"local";
		}
	}
	return self;
}

-(void)dealloc
{
	self.state = nil;
	[_gameData release], _gameData = nil;
	self.gameRoot = nil;
	self.localPlayerGameCenterId = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Singleton

+(FCGameContext*)instance
{
	static FCGameContext* theInstance = nil;
	
	if (!theInstance) {
		theInstance = [FCGameContext alloc];
		[theInstance init];
	}
	return theInstance;
}

@end

#endif // TARGET_OS_IPHONE
