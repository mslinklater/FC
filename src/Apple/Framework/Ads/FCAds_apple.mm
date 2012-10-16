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

#if defined( FC_ADS )

#import "FCAds_apple.h"
#import "FCAdBannerView_apple.h"
#import "FCViewManager_apple.h"
#import "FCApplication_apple.h"

void plt_FCAds_ShowBanner( const char* key );
void plt_FCAds_HideBanner();

static FCAdBannerView_apple* s_bannerView = nil;
extern UIViewController* s_rootViewController;

void plt_FCAds_ShowBanner(const char* adWhirlKey)
{
	if ( s_bannerView == nil) 
	{
		s_bannerView = [[FCAdBannerView_apple alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
															   key:@(adWhirlKey)];
        
        [s_rootViewController.view addSubview:s_bannerView];
        [s_rootViewController.view bringSubviewToFront:s_bannerView];
		s_bannerView.viewController = FCRootViewController();
	}
}

void plt_FCAds_HideBanner()
{
	if (s_bannerView) 
	{
		FCViewManager_apple* vm = [FCViewManager_apple instance];
		[s_bannerView removeFromSuperview];
		[vm remove:@"adbanner"];
		s_bannerView = nil;
	}
}

#endif // FC_ADS
