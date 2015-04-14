//
//  MLAfterSalesServiceViewController.m
//  MoLi
//
//  Created by zhangbin on 12/16/14.
//  Copyright (c) 2014 zoombin. All rights reserved.
//

#import "MLAfterSalesServiceViewController.h"
#import "Header.h"
#import "ZBBottomIndexView.h"
#import "MLAfterSalesGoodsTableViewCell.h"
#import "MLAfterSalesGoods.h"
#import "MLOrderFooterView.h"
#import "MLAskForAfterSalesViewController.h"
#import "MLAfterSalesLogisticViewController.h"
#import "MLNoDataView.h"
#import "MLAfterSaleServiceDetailViewController.h"

@interface MLAfterSalesServiceViewController () <
MLOrderFooterViewDelegate,
ZBBottomIndexViewDelegate,
UITableViewDataSource, UITableViewDelegate
>

@property (readwrite) UITableView *tableView;
@property (readwrite) ZBBottomIndexView *bottomIndexView;
@property (readwrite) NSInteger page;
@property (readwrite) NSArray *multiAfterSalesGoods;
@property (readwrite) MLNoDataView *noDataView;

@end

@implementation MLAfterSalesServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor backgroundColor];
	self.title = NSLocalizedString(@"售后服务", nil);
	[self setLeftBarButtonItemAsBackArrowButton];
	_page = 1;
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self.view addSubview:_tableView];
	
	_bottomIndexView = [[ZBBottomIndexView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 34)];
	[_bottomIndexView setItems:@[@"退货中", @"换货中"]];
	[_bottomIndexView setIndexColor:[UIColor themeColor]];
	[_bottomIndexView setTitleColor:[UIColor lightGrayColor]];
	[_bottomIndexView setTitleColorSelected:[UIColor themeColor]];
	_bottomIndexView.delegate = self;
	[_bottomIndexView setFont:[UIFont systemFontOfSize:15]];
	_tableView.tableHeaderView = _bottomIndexView;
	
	_noDataView = [[MLNoDataView alloc] initWithFrame:self.view.bounds];
	_noDataView.imageView.image = [UIImage imageNamed:@"NoAfterSales"];
	_noDataView.label.text = @"亲，您还没有换货的商品哦";
	_noDataView.hidden = YES;
	[self.view addSubview:_noDataView];
	
	[self.view addGestureRecognizer:[_bottomIndexView leftSwipeGestureRecognizer]];
	[self.view addGestureRecognizer:[_bottomIndexView rightSwipeGestureRecognizer]];
	
	[self fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchData {
	BOOL changeInfo = _bottomIndexView.selectedIndex == 1;
	[self displayHUD:@"加载中..."];
	[[MLAPIClient shared] afterSalesGoodsChange:changeInfo page:@(_page) withBlock:^(NSArray *multiAttributes, MLResponse *response) {
		[self displayResponseMessage:response];
		if (response.success) {
			_multiAfterSalesGoods = [MLAfterSalesGoods multiWithAttributesArray:multiAttributes];
			_noDataView.hidden = _multiAfterSalesGoods.count ? YES : NO;
			[_tableView reloadData];
		}
	}];
}

#pragma mark - ZBBottomIndexView

- (void)bottomIndexViewSelected:(NSInteger)selectedIndex {
	[self fetchData];
}

#pragma mark - MLOrderFooterViewDelegate

- (void)executeAfterSalesGoods:(MLAfterSalesGoods *)afterSalesGoods withOperator:(MLOrderOperator *)orderOperator {
	NSString *identifier = [MLOrderOperator identifierForType:orderOperator.type];
	if (identifier) {
		[self displayHUDTitle:nil message:@"加载中..."];
		[[MLAPIClient shared] operateOrder:nil orderOperator:orderOperator afterSalesGoods:afterSalesGoods password:nil withBlock:^(NSDictionary *attributes, MLResponse *response) {
			[self displayResponseMessage:response];
			if (response.success) {
				[self fetchData];
			}
		}];
		return;
	}
	
	Class class = [MLOrderOperator classForType:orderOperator.type];
	if (class) {
		if (class == [MLAskForAfterSalesViewController class]) {
			MLAskForAfterSalesViewController *viewController = [[MLAskForAfterSalesViewController alloc] initWithNibName:nil bundle:nil];
			viewController.hidesBottomBarWhenPushed = YES;
			viewController.afterSalesGoods = afterSalesGoods;
			[self.navigationController pushViewController:viewController animated:YES];
		} else if (class == [MLAfterSalesLogisticViewController class]) {
			MLAfterSalesLogisticViewController *viewController = [[MLAfterSalesLogisticViewController alloc] initWithNibName:nil bundle:nil];
			viewController.hidesBottomBarWhenPushed = YES;
			viewController.afterSalesGoods = afterSalesGoods;
			[self.navigationController pushViewController:viewController animated:YES];
		}
		return;
	}
}

#pragma mark - UITabelViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	MLAfterSalesGoods *afterSalesGoods = _multiAfterSalesGoods[section];
	if (afterSalesGoods.orderOperators.count > 0) {
		return [MLOrderFooterView height];
	}
	return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [MLAfterSalesGoodsTableViewCell height];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _multiAfterSalesGoods.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] init];
	MLOrderFooterView *orderFooterView = [[MLOrderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [MLOrderFooterView height])];
	MLAfterSalesGoods *afterSalesGoods = _multiAfterSalesGoods[section];
	orderFooterView.afterSalesGoods = afterSalesGoods;
	orderFooterView.delegate = self;
	if (afterSalesGoods.orderOperators.count) {
		[view addSubview:orderFooterView];
	}
	return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MLAfterSalesGoodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell identifier]];
	if (!cell) {
		cell = [[MLAfterSalesGoodsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[MLAfterSalesGoodsTableViewCell identifier]];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	cell.afterSalesGoods = _multiAfterSalesGoods[indexPath.section];
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLAfterSaleServiceDetailViewController *afterServiceCtr = [[MLAfterSaleServiceDetailViewController alloc] init];
    afterServiceCtr.afterGoods = _multiAfterSalesGoods[indexPath.section];
    [self.navigationController pushViewController:afterServiceCtr animated:YES];
}

@end
