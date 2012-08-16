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
#import <GameKit/GameKit.h>

#include "Shared/Framework/Online/FCOnline_platform.h"

@interface FCOnlineLeaderboard_apple : NSObject <GKLeaderboardViewControllerDelegate> {
    GKLocalPlayer*  _localPlayer;
}
@property(nonatomic, strong) GKLocalPlayer* localPlayer;

+(FCOnlineLeaderboard_apple*)instance;

-(void)authenticateLocalPlayer;

-(void)postScore:(unsigned int)score
   toLeaderboard:(NSString*)leaderboardName
      withHandle:(unsigned int)handle
        callback:(plt_FCOnlineLeaderboard_PostCallback)callback;

-(void)show;
@end
