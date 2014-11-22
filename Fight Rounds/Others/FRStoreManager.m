//
//  FRStoreManager.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 1/09/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

@import StoreKit;

#import "FRStoreManager.h"

#define PURCHASE_ALERT_TAG 200

@interface FRStoreManager () <UIAlertViewDelegate>

@property (strong, nonatomic) SKProduct *purchasingProduct;

@end

@implementation FRStoreManager

+ (instancetype)sharedManager {
	static __DISPATCH_ONCE__ id singletonObject = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    singletonObject = [[self alloc] init];
	});

	return singletonObject;
}

- (BOOL)upgradeToFullVersion {
//    if ([SKPaymentQueue canMakePayments]) {
//        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Product_IDs"
//                                              withExtension:@"plist"];
//        [self validateProductIdentifiers:[NSArray arrayWithContentsOfURL:url]];
//    } else {
//        return NO;
//    }
//
	return YES;
}

#pragma mark - Private



//- (void)validateProductIdentifiers:(NSArray *)productIdentifiers
//{
//    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
//    productsRequest.delegate = self;
//    [productsRequest start];
//}
//
//// SKProductsRequestDelegate protocol method
//- (void)productsRequest:(SKProductsRequest *)request
//     didReceiveResponse:(SKProductsResponse *)response
//{
//    NSArray *products = response.products;
//
//    for (NSString * invalidProductIdentifier in response.invalidProductIdentifiers) {
//        // Handle any invalid product identifiers.
//    }
//
//    self.purchasingProduct = [response.products lastObject];
//
//    [self presentStore];
//}
//
//- (void)presentStore
//{
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//    [numberFormatter setLocale:self.purchasingProduct.priceLocale];
//
//    NSString *formattedPrice = [numberFormatter stringFromNumber:self.purchasingProduct.price];
//
//    NSString *title = [[NSString alloc] initWithFormat:@"Purchase \"%@\"", self.purchasingProduct.localizedTitle];
//    NSString *message = [[NSString alloc] initWithFormat:@"Upgrade to the full version for %@? You will only have to this once for all your devices", formattedPrice];
//
//    UIAlertView *purchaseAlertView = [[UIAlertView alloc] initWithTitle:title
//                                                                message:message
//                                                               delegate:self
//                                                      cancelButtonTitle:@"No"
//                                                      otherButtonTitles:@"Yes", nil];
//    purchaseAlertView.tag = PURCHASE_ALERT_TAG;
//    [purchaseAlertView show];
//}
//
//#pragma mark - Payment Queue
//
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//
//    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction *transaction, NSUInteger idx, BOOL *stop) {
//        switch (transaction.transactionState) {
//            case SKPaymentTransactionStatePurchased:
//            case SKPaymentTransactionStateRestored:
//                [defaults setBool:YES forKey:DEFAULTS_IN_APP_PURCHASED];
//                [defaults synchronize];
//                break;
//
//            case SKPaymentTransactionStatePurchasing:
//
//                break;
//
//            case SKPaymentTransactionStateFailed:
//
//                break;
//
//            default:
//                break;
//        }
//    }];
//}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == PURCHASE_ALERT_TAG) {
		if (buttonIndex == 1) {
			SKPayment *payment = [SKPayment paymentWithProduct:self.purchasingProduct];
			[[SKPaymentQueue defaultQueue] addPayment:payment];
		}
	}
}

@end
