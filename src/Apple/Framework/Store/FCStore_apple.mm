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

#import "FCStore_apple.h"
#import "VerificationController.h"

#include "Shared/FCPlatformInterface.h"

static FCStore_apple* s_pInstance = 0;

void plt_FCStore_WarmBoot()
{
	[[FCStore_apple instance] warmBoot];
}

bool plt_FCStore_Available()
{
	return [[FCStore_apple instance] available];
}

void plt_FCStore_ClearItemRequestList()
{
	[[FCStore_apple instance] clearItemRequests];
}

void plt_FCStore_AddItemRequest( const char* itemId )
{
	[[FCStore_apple instance] addItemRequest:@(itemId)];
}

void plt_FCStore_ProcessItemRequestList()
{
	[[FCStore_apple instance] processItemRequests];
}

void plt_FCStore_PurchaseRequest( const char* identifier )
{
	[[FCStore_apple instance] purchaseRequest:@(identifier)];
}

@implementation FCStore_apple

+(FCStore_apple*)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCStore_apple alloc] init];
	}
	return s_pInstance;
}

-(void)warmBoot
{
	NSLog(@"Apple: FCStore WarmBoot");
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(BOOL)available
{
	if ([SKPaymentQueue canMakePayments])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

-(void)clearItemRequests
{
	_itemRequestSet = [NSMutableSet set];
}

-(void)addItemRequest:(NSString*)itemId
{
	[_itemRequestSet addObject:itemId];
}

-(void)processItemRequests
{
	SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:_itemRequestSet];
	request.delegate = self;
	[request start];
}

-(void)purchaseRequest:(NSString *)identifier
{
	
	for( SKProduct* product in _products )
	{
		if ([product.productIdentifier isEqualToString:identifier])
		{
			SKPayment* payment = [SKPayment paymentWithProduct:product];
			[[SKPaymentQueue defaultQueue] addPayment:payment];
		}
	}
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
    VerificationController * verifier = [VerificationController sharedInstance];
    [verifier verifyPurchase:transaction completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Successfully verified receipt!");
			fc_FCStore_PurchaseSuccessful( [transaction.payment.productIdentifier UTF8String] );
        } else {
            NSLog(@"Failed to validate receipt.");
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
			fc_FCStore_PurchaseFailed( [transaction.payment.productIdentifier UTF8String] );
        }
    }];
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	_products = response.products;
	
	fc_FCStore_ClearStoreItems();
	
	for( SKProduct* product in _products )
	{
		NSString* currencySymbol = [product.priceLocale objectForKey:NSLocaleCurrencySymbol];
		
		fc_FCStore_AddStoreItem( [product.localizedTitle UTF8String], [[NSString stringWithFormat:@"%@%@", currencySymbol, product.price] UTF8String], [product.productIdentifier UTF8String]);
	}
	fc_FCStore_EndStoreItems();
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
			{
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				[self validateReceiptForTransaction:transaction];
//				fc_FCStore_PurchaseSuccessful( [transaction.payment.productIdentifier UTF8String] );
				
                break;
				
			}
            case SKPaymentTransactionStateFailed:
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				fc_FCStore_PurchaseFailed( [transaction.payment.productIdentifier UTF8String] );
                break;
            case SKPaymentTransactionStateRestored:
				assert(0);
				NSLog(@"Restored");
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
            case SKPaymentTransactionStatePurchasing:
				NSLog(@"Purchasing");
				break;
            default:
                break;
        }
    }
}

@end
