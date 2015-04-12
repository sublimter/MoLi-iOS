//
//  MLPaymentViewController.m
//  MoLi
//
//  Created by zhangbin on 12/15/14.
//  Copyright (c) 2014 zoombin. All rights reserved.
//

#import "MLPaymentViewController.h"
#import "ZBPaymentManager.h"
#import "Header.h"

@interface MLPaymentViewController () <UITableViewDataSource, UITableViewDelegate>

@property (readwrite) UITableView *tableView;

@end

@implementation MLPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor backgroundColor];
	self.title = NSLocalizedString(@"魔力收银台", nil);
	[self setLeftBarButtonItemAsBackArrowButton];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] init];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tableView.separatorInset.left, 10, tableView.bounds.size.width - 2 * tableView.separatorInset.left, 45 - 10)];
	label.text = NSLocalizedString(@"请选择支付方式", nil);
	label.textColor = [UIColor fontGrayColor];
	label.font = [UIFont systemFontOfSize:16];
	[view addSubview:label];
	
	UILabel *priceLabel = [[UILabel alloc] initWithFrame:label.frame];
	priceLabel.textColor = [UIColor themeColor];
	priceLabel.textAlignment = NSTextAlignmentRight;
	priceLabel.font = [UIFont systemFontOfSize:16];
	priceLabel.text = [NSString stringWithFormat:@"¥%@", _payment.payAmount];
	[view addSubview:priceLabel];
	return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell identifier]];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITableViewCell identifier]];
	}
	if (indexPath.row == 0) {
		cell.imageView.image = [UIImage imageNamed:@"WeChat"];
		cell.textLabel.text = NSLocalizedString(@"微信支付", nil);
	} else {
		cell.imageView.image = [UIImage imageNamed:@"Alipay"];
		cell.textLabel.text = NSLocalizedString(@"支付宝支付", nil);
	}
	cell.textLabel.textColor = [UIColor fontGrayColor];
	cell.textLabel.font = [UIFont systemFontOfSize:16];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *priceString = [NSString stringWithFormat:@"%@", _payment.payAmount];
#warning TODO hardcode price to test payment
	priceString = @"0.01";
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZBPaymentType type = ZBPaymentTypeAlipay;
    if (indexPath.row == 0) {
        type = ZBPaymentTypeWeixin;
    }
	
	[self displayHUD:@"加载中..."];
	[[MLAPIClient shared] callbackOfPaymentID:_payment.ID paymentType:type withBlock:^(NSString *callbackURLString, MLResponse *response) {
		[self displayResponseMessage:response];
		if (response.success) {
			NSLog(@"payment: %@", _payment);
			NSLog(@"callback: %@", callbackURLString);
			[[ZBPaymentManager shared] pay:type price:priceString orderID:_payment.ID name:_payment.paySubject description:_payment.payBody callbackURLString:callbackURLString withBlock:^(BOOL success) {
				if (success) {
					NSLog(@"成功");
				} else {
					NSLog(@"失败");
				}
			}];
		}
	}];
	
}

@end
