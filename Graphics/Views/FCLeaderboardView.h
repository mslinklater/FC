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

enum FCLeaderboardViewActiveBoard {
	kFCLeaderboardViewLocal,
	kFCLeaderboardViewFriends,
	kFCLeaderboardViewWorld
};

@class FCLeaderboardView;

@protocol FCLeaderboardViewDelegate
-(int)leaderboardView:(FCLeaderboardView*)view numberOfRowsInActive:(FCLeaderboardViewActiveBoard)active;
-(int)leaderboardView:(FCLeaderboardView *)view scoreForActive:(FCLeaderboardViewActiveBoard)active row:(int)row;
-(NSString*)leaderboardView:(FCLeaderboardView *)view nameForActive:(FCLeaderboardViewActiveBoard)active row:(int)row;
@end

@interface FCLeaderboardView : UIView <UITableViewDelegate, UITableViewDataSource> {
    FCLeaderboardViewActiveBoard mActiveBoard;
}
@property(nonatomic, strong) UIButton* localButton;
@property(nonatomic, strong) UIButton* friendsButton;
@property(nonatomic, strong) UIButton* worldButton;
@property(nonatomic, strong) UITableView* tableView;
@property(nonatomic, unsafe_unretained) id<FCLeaderboardViewDelegate> tableViewDelegate;

@end

#endif // TARGET_OS_IPHONE
