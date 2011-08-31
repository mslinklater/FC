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

#import "FCCore.h"
#import "FCStats.h"
#import "FCPersistentData.h"
#import "FCGameContext.h"

//----------------------------------------------------------------------------------------------------------------------

#pragma mark - FCStat

@implementation FCStat

@synthesize textString = _textString;
@synthesize numberValue = _numberValue;

#pragma mark - NSCoding protocol

-(id)init
{
	self = [super init];
	if (self) {
		// blah
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.textString forKey:@"textString"];
	[encoder encodeInt32:self.numberValue forKey:@"numberValue"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	
	if (self) {
		[self setTextString:[decoder decodeObjectForKey:@"textString"]];
		[self setNumberValue:[decoder decodeInt32ForKey:@"numberValue"]];
	}
	
	return self;
}

@end

//----------------------------------------------------------------------------------------------------------------------

#pragma mark - FCStats

static FCStats* FCStatsInstance = 0;

@implementation FCStats

@synthesize userStats = _userStats;

+(FCStats*)instance
{
	if (!FCStatsInstance) {
		FCStatsInstance = [[FCStats alloc] init];
	}
	return FCStatsInstance;
}

-(id)init
{
	self = [super init];
	if (self) 
	{
	}
	return self;
}

-(void)dealloc
{
	[userStats release]; userStats = 0;
	[super dealloc];
}

-(void)prepareStatsFromArray:(NSArray*)statsArray withPlayerId:(id)playerId
{
	FC_LOG1(@"Preparing stats array with player ID:", playerId);
	
	NSDictionary* dataRoot = [[FCPersistentData instance] dataRoot];
	
	userStats = [dataRoot valueForKey:@"userStatsDictionary"];
	
	if (!self.userStats)
	{
		self.userStats = [NSMutableDictionary dictionary];
		[dataRoot setValue:userStats forKey:@"userStatsDictionary"];
	}
//	else
//	{
//		[userStats retain];
//	}
	
	// go through statsArray and add any new ones to the stats array.
	
	NSMutableDictionary* statsDictionary = [userStats valueForKey:playerId];
	
	if (!statsDictionary) 
	{
		statsDictionary = [NSMutableDictionary dictionary];
		[self.userStats setObject:statsDictionary forKey:playerId];
	}
	
	for( NSDictionary* entry in statsArray )
	{
		NSString* key = [entry valueForKey:@"key"];
		NSString* text = [entry valueForKey:@"text"];
		
		if (![statsDictionary valueForKey:key]) 
		{
			// new stat, so add it to the stats array
			
			FCStat* newStat = [[FCStat alloc] init];
			newStat.textString = text;
			newStat.numberValue = 0;
			[statsDictionary setObject:newStat forKey:key];
			[newStat release];
		}
	}
	
	FC_LOG(@"end stats");
}

-(void)incrementKey:(NSString*)key
{
	FCStat* thisStat = [[self.userStats objectForKey:[[FCGameContext instance] localPlayerGameCenterId]] objectForKey:key];
	thisStat.numberValue++;
}

@end

#endif // TARGET_OS_IPHONE
