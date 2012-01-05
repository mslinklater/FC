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

#import "FCLeaderboardView.h"
#import "FCLeaderboardCell.h"
#import "FCCategories.h"

static const float kGapBetweenButtons = 5;
static const float kBorder = 5;
static const float kButtonHeight = 30;

@interface FCLeaderboardView(hidden)
-(void)localButtonPressed:(id)sender;
-(void)friendsButtonPressed:(id)sender;
-(void)worldButtonPressed:(id)sender;
@end

@implementation FCLeaderboardView

@synthesize localButton = _localButton;
@synthesize friendsButton = _friendsButton;
@synthesize worldButton = _worldButton;
@synthesize tableView = _tableView;
@synthesize tableViewDelegate = _tableViewDelegate;

#pragma mark - Object Lifetime

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		
		float buttonWidth = (self.width - (2 * kGapBetweenButtons) - (2 * kBorder)) / 3;

		_localButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.localButton.frame = CGRectMake(kBorder, kBorder, buttonWidth, kButtonHeight);
		[self.localButton addTarget:self action:@selector(localButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.localButton];
		
		_friendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.friendsButton.frame = CGRectMake(kBorder + buttonWidth + kGapBetweenButtons, kBorder, buttonWidth, kButtonHeight);
		[self.friendsButton addTarget:self action:@selector(friendsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.friendsButton];
		
		_worldButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.worldButton.frame = CGRectMake(kBorder + ((buttonWidth + kGapBetweenButtons) * 2), kBorder, buttonWidth, kButtonHeight);
		[self.worldButton addTarget:self action:@selector(worldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.worldButton];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(kBorder, kBorder * 2 + kButtonHeight, self.width - (kBorder * 2), self.height - (kBorder * 2 + kButtonHeight))];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.backgroundColor = [UIColor clearColor];
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		[self addSubview:self.tableView];
		
		mActiveBoard = kFCLeaderboardViewLocal;
    }
    return self;
}


#pragma mark - Button responders

-(void)localButtonPressed:(id)sender
{
	mActiveBoard = kFCLeaderboardViewLocal;
}

-(void)friendsButtonPressed:(id)sender
{
	mActiveBoard = kFCLeaderboardViewFriends;
}

-(void)worldButtonPressed:(id)sender
{
	mActiveBoard = kFCLeaderboardViewWorld;
}

#pragma mark - Setters

#pragma mark - Getters

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [FCLeaderboardCell height];
}

//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{}
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{}
//- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPat{}
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{}

#pragma mark - UITableViewDataSource

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FCLeaderboardCell *cell = (FCLeaderboardCell*)[tableView dequeueReusableCellWithIdentifier:@"FCLeaderboardCell"];
	if (!cell) {
		cell = [[FCLeaderboardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FCLeaderboardCell"];
		[cell setWidth:self.width - (kBorder * 2)];
		cell.nameLabel.text = [self.tableViewDelegate leaderboardView:self nameForActive:mActiveBoard row:[indexPath row]];
		int score = [self.tableViewDelegate leaderboardView:self scoreForActive:mActiveBoard row:[indexPath row]];
		cell.scoreLabel.text = [NSString stringWithFormat:@"%d", score];	// TODO: need a better formatter here
	}
	return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.tableViewDelegate leaderboardView:self numberOfRowsInActive:mActiveBoard];
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{}
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{}
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{}
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{}
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{}


@end

#endif // TARGET_OS_IPHONE
