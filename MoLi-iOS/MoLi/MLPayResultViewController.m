//
//  MLPaySuccessViewController.m
//  TestCelectionView
//
//  Created by imooly-mac on 15/4/1.
//  Copyright (c) 2015年 imooly-mac. All rights reserved.
//

#import "MLPayResultViewController.h"
#import "MLPaySuccessView.h"
#import "MLPayFailView.h"

#define DEF_IOS7LATTER [[[UIDevice currentDevice] systemVersion] floatValue ] >= 7.0

@interface MLPayResultViewController () <MLPaySuccessDelegate, MLPayFailDelegate>

@end

@implementation MLPayResultViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.hidesBackButton = YES;
    CGRect rect = self.view.frame;
    rect.size.height = 175;
    if (DEF_IOS7LATTER) {
        rect.origin.y = 84;
    }
	if (_success) {
		self.title = @"支付成功";
		rect.size.height += 100;
		MLPaySuccessView *payView = [[MLPaySuccessView alloc] initWithFrame:rect];
		payView.delegate = self;
		payView.orderNumber.text = [NSString stringWithFormat:@"%@", _payment.ID];
		payView.payMoney.text = [NSString stringWithFormat:@"%@", _payment.payAmount];
		if (_paymentType == ZBPaymentTypeAlipay) {
			payView.payType.text = @"支付宝";
		} else if (_paymentType == ZBPaymentTypeWeixin) {
			payView.payType.text = @"微信";
		}
		[self.view addSubview:payView];
	} else {
		self.title = @"支付失败";
		MLPayFailView *payView = [[MLPayFailView alloc] initWithFrame:rect];
		payView.delegate = self;
		[self.view addSubview:payView];
	}
}

- (void)goShoppingAfterPay {
	[self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)goOrdersAfterPay {
	[self.navigationController popToRootViewControllerAnimated:NO];
	NSNotification *notification = [[NSNotification alloc] initWithName:ML_NOTIFICATION_IDENTIFIER_OPEN_ORDERS object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)retryAfterPay {
	[self.navigationController popViewControllerAnimated:NO];
	if (_delegate) {
		[_delegate repay];
	}
}

- (void)lookingAroundAfterPay {
	[self.navigationController popToRootViewControllerAnimated:NO];
}


@end