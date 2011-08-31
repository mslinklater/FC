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

#import "FCLeaderboardCell.h"
#import "FC.h"

static const float kBorder = 10;
static const float kNameHeight = 20;
static const float kScoreHeight = 24;

@implementation FCLeaderboardCell

@synthesize scoreLabel = _scoreLabel;
@synthesize nameLabel = _nameLabel;

#pragma mark - Object Lifetime

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBorder, ([FCLeaderboardCell height] / 2) - (kNameHeight / 2), self.halfWidth - kBorder, kNameHeight)];
		self.nameLabel.backgroundColor = [UIColor clearColor];		
		self.nameLabel.textColor = [UIColor whiteColor];
		self.nameLabel.textAlignment = UITextAlignmentLeft;
		[self addSubview:self.nameLabel];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.halfWidth, ([FCLeaderboardCell height] / 2) - (kScoreHeight / 2), self.halfWidth - kBorder, kScoreHeight)];
		self.scoreLabel.backgroundColor = [UIColor clearColor];
		self.scoreLabel.textColor = [UIColor whiteColor];
		self.scoreLabel.textAlignment = UITextAlignmentRight;
		[self addSubview:self.scoreLabel];
    }
    return self;
}

-(void)dealloc
{
	self.nameLabel = nil;
    [super dealloc];
}

#pragma mark - Layout

-(void)setWidth:(float)newWidth
{
	self.nameLabel.frame = CGRectMake(kBorder, ([FCLeaderboardCell height] / 2) - (kNameHeight / 2), (newWidth / 2) - kBorder, kNameHeight);
	self.scoreLabel.frame = CGRectMake(newWidth / 2, ([FCLeaderboardCell height] / 2) - (kScoreHeight / 2), (newWidth / 2) - kBorder, kScoreHeight);
}

+(float)height
{
	return kBorder * 2 + MAX(kNameHeight, kScoreHeight);
}

@end

#endif // TARGET_OS_IPHONE
