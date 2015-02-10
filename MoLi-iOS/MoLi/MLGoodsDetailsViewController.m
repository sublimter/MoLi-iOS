//
//  MLGoodsDetailsViewController.m
//  MoLi
//
//  Created by zhangbin on 12/20/14.
//  Copyright (c) 2014 zoombin. All rights reserved.
//

#import "MLGoodsDetailsViewController.h"
#import "Header.h"
#import "MLGoodsProperty.h"
#import "MLGoodsImagesDetailsViewController.h"
#import "MLGalleryCollectionViewCell.h"
#import "MLGoodsInfoCollectionViewCell.h"
#import "MLCommonCollectionViewCell.h"
#import "MLGoodsCollectionViewCell.h"
#import "MLGoodsIntroduceCollectionViewCell.h"
#import "MLSigninViewController.h"
#import "IIViewDeckController.h"
#import "MLFlagStoreCollectionViewCell.h"
#import "MLFlagshipStore.h"
#import "MLVoucher.h"
#import "MLVoucherCollectionViewCell.h"
#import "MLFlagshipStoreViewController.h"

static CGFloat const heightOfAddCartView = 50;
static CGFloat const heightOfTabBar = 49;
static CGFloat const minimumInteritemSpacing = 18;

@interface MLGoodsDetailsViewController () <
MLGoodsInfoCollectionViewCellDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
>

@property (readwrite) UICollectionView *collectionView;
@property (readwrite) UILabel *headerLabel;
@property (readwrite) UIView *introduceView;
@property (readwrite) UILabel *introduceLabel;
@property (readwrite) UIScrollView *galleryScrollView;
@property (readwrite) UIPageControl *pageControl;
@property (readwrite) UIView *addCartView;
@property (readwrite) NSMutableArray *sectionClasses;
@property (readwrite) NSArray *relatedMultiGoods;
@property (readwrite) BOOL showIndroduce;
@property (readwrite) MLFlagshipStore *flagshipStore;
@property (readwrite) MLVoucher *voucher;
@property (readwrite) CGRect addCartViewOriginRect;

@end

@implementation MLGoodsDetailsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor backgroundColor];
	
	_sectionClasses = [@[[MLGalleryCollectionViewCell class],
						[MLGoodsInfoCollectionViewCell class],
						[MLCommonCollectionViewCell class],
						[MLCommonCollectionViewCell class],
						[MLGoodsIntroduceCollectionViewCell class],
						[MLCommonCollectionViewCell class],
						[MLFlagStoreCollectionViewCell class],
						[MLVoucherCollectionViewCell class],
						[MLGoodsCollectionViewCell class]
						] mutableCopy];
	
	CGRect rect = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - heightOfAddCartView);
	
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	layout.minimumInteritemSpacing = minimumInteritemSpacing;
	_collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	_collectionView.backgroundColor = self.view.backgroundColor;
	for (int i = 0; i < _sectionClasses.count; i++) {
		Class class = _sectionClasses[i];
		[_collectionView registerClass:class forCellWithReuseIdentifier:[class identifier]];
	}
	[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
	[self.view addSubview:_collectionView];
	
	rect.origin.x = 0;
	rect.origin.y = self.view.frame.size.height - heightOfAddCartView - heightOfTabBar;
	rect.size.width = self.view.frame.size.width;
	rect.size.height = heightOfAddCartView;
	_addCartViewOriginRect = rect;
	_addCartView = [[UIView alloc] initWithFrame:rect];
	_addCartView.opaque = YES;
	_addCartView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	[self.view addSubview:_addCartView];
	
	rect.origin.y = 0;
	rect.size.width = (self.view.frame.size.width - heightOfAddCartView) / 2;
	UIButton *addCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addCartButton.frame = rect;
	[addCartButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
	[addCartButton setTitle:NSLocalizedString(@"加入购物车", nil) forState:UIControlStateNormal];
	[addCartButton addTarget:self action:@selector(willAddCart) forControlEvents:UIControlEventTouchUpInside];
	[_addCartView addSubview:addCartButton];

	rect.origin.x = CGRectGetMaxX(addCartButton.frame);
	UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	buyButton.frame = rect;
	buyButton.backgroundColor = [UIColor themeColor];
	[buyButton setTitle:NSLocalizedString(@"立即购买", nil) forState:UIControlStateNormal];
	[buyButton addTarget:self action:@selector(willAddCart) forControlEvents:UIControlEventTouchUpInside];
	[_addCartView addSubview:buyButton];
	
	rect.origin.x = CGRectGetMaxX(buyButton.frame);
	rect.size.width = heightOfAddCartView;
	UIButton *hideAddCartViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	hideAddCartViewButton.frame = rect;
	//[hideAddCartViewButton setTitle:@"隐藏" forState:UIControlStateNormal];
	[hideAddCartViewButton setImage:[UIImage imageNamed:@"Girl"] forState:UIControlStateNormal];
//	[hideAddCartViewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
	[hideAddCartViewButton addTarget:self action:@selector(hideOrShowAddCartView) forControlEvents:UIControlEventTouchUpInside];
	[_addCartView addSubview:hideAddCartViewButton];
	
	_introduceLabel = [[UILabel alloc] init];
	_introduceLabel.numberOfLines = 0;
	_introduceLabel.font = [UIFont systemFontOfSize:15];
	_introduceLabel.textColor = [UIColor fontGrayColor];
	_introduceLabel.backgroundColor = _collectionView.backgroundColor;
	
	_introduceView = [[UIView alloc] init];
	_introduceView.backgroundColor = _collectionView.backgroundColor;
	[_introduceView addSubview:_introduceLabel];
	
	UIImage *backImage = [UIImage imageNamed:@"Back"];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(20, 32, backImage.size.width, backImage.size.height);
	[backButton setImage:backImage forState:UIControlStateNormal];
	backButton.showsTouchWhenHighlighted = YES;
	[backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIImage *shareImage = [UIImage imageNamed:@"Share"];
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(self.view.bounds.size.width - 20 - shareImage.size.width, 32, shareImage.size.width, shareImage.size.height);
	[shareButton setImage:shareImage forState:UIControlStateNormal];
	shareButton.showsTouchWhenHighlighted = YES;
	[shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:shareButton];
	
	NSLog(@"goods id: %@", _goods.ID);
	
	[[MLAPIClient shared] goodsDetails:_goods.ID withBlock:^(NSDictionary *attributes, NSArray *multiAttributes, MLResponse *response) {
		[self displayResponseMessage:response];
		if (response.success) {
			_goods = [[MLGoods alloc] initWithAttributes:attributes];
			_relatedMultiGoods = [MLGoods multiWithAttributesArray:multiAttributes];
			
			if ([response.data[@"store"] notNull]) {
				_flagshipStore = [[MLFlagshipStore alloc] initWithAttributes:response.data[@"store"]];
			} else {
				[_sectionClasses removeObject:[MLFlagStoreCollectionViewCell class]];
			}
			
			if ([response.data[@"isvoucher"] boolValue]) {
				_voucher = [[MLVoucher alloc] init];
				_voucher.imagePath = response.data[@"voucherimage"];
				_voucher.voucherWillGetRange = response.data[@"voucher"];
			} else {
				[_sectionClasses removeObject:[MLVoucherCollectionViewCell class]];
			}
			
			CGRect frame = CGRectZero;
			frame.origin.y = [MLGoodsIntroduceCollectionViewCell height];
			frame.size.width = _collectionView.bounds.size.width;
			frame.size.height = [MLGoodsIntroduceCollectionViewCell heightPerIntroduceElementLine ] * [_goods linesForMultiIntroduce];
			_introduceView.frame = frame;
			
			frame.origin.x = minimumInteritemSpacing;
			frame.origin.y = 0;
			frame.size.width = frame.size.width - 2 * frame.origin.x;
			_introduceLabel.frame = frame;
			_introduceLabel.text = [_goods formattedIntroduce];
			
			[_collectionView reloadData];
			
			[[MLAPIClient shared] goodsProperties:_goods.ID withBlock:^(NSArray *multiAttributes, NSError *error) {
				if (!error) {
					NSArray *goodsProperties = [MLGoodsProperty multiWithAttributesArray:multiAttributes];
					_goods.goodsProperties = [NSArray arrayWithArray:goodsProperties];
					_propertiesPickerViewController.goods = _goods;
				}
			}];
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self hideAddCartView:NO];
}

- (void)willAddCart {
	[self hideAddCartView:YES];
	[self.viewDeckController toggleRightView];
}

- (void)hideOrShowAddCartView {
	[self hideAddCartView:!self.tabBarController.tabBar.hidden];
}

- (void)hideAddCartView:(BOOL)hidden {
	self.tabBarController.tabBar.hidden = hidden;
	CGRect rect = _addCartViewOriginRect;
	if (hidden) {
		rect.origin.y += heightOfTabBar;
	}
	_addCartView.frame = rect;
}

- (void)back {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)share {
	[[MLAPIClient shared] shareWithObject:MLShareObjectGoods platform:MLSharePlatformQQ objectID:_goods.ID withBlock:^(NSDictionary *attributes, MLResponse *response) {
		[self displayResponseMessage:response];
		if (response.success) {
			MLShare *share = [[MLShare alloc] initWithAttributes:attributes];
			[UMSocialSnsService presentSnsIconSheetView:self appKey:ML_UMENG_APP_KEY shareText:share.word shareImage:[UIImage imageNamed:@"MoliIcon"] shareToSnsNames:@[UMShareToSina, UMShareToQzone, UMShareToQQ, UMShareToWechatTimeline, UMShareToWechatSession] delegate:nil];
		}
	}];
}

#pragma mark - MLGoodsInfoCollectionViewCellDelegate

- (void)goods:(MLGoods *)goods farovite:(BOOL)favorite {
	[self displayHUD:@"加载中..."];
	[[MLAPIClient shared] goods:goods.ID favour:favorite withBlock:^(NSString *message, NSError *error) {
		if (!error) {
			if (message.length) {
				[self displayHUDTitle:nil message:message];
			} else {
				[self hideHUD:YES];
			}
			_goods.favorited = @(favorite);
			[_collectionView reloadData];
		} else {
			[self displayHUDTitle:nil message:error.userInfo[ML_ERROR_MESSAGE_IDENTIFIER]];
		}
	}];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
	Class class = _sectionClasses[indexPath.section];
	CGFloat height = [class height];
	CGFloat width = collectionView.bounds.size.width;
	flowLayout.headerReferenceSize = CGSizeMake(collectionView.bounds.size.width, 5);
	if (class == [MLGoodsCollectionViewCell class]) {
		flowLayout.headerReferenceSize = CGSizeMake(collectionView.bounds.size.width, 40);
		width = [class size].width;
	} else if (class == [MLGoodsIntroduceCollectionViewCell class]) {
		if (_showIndroduce) {
			height += [MLGoodsIntroduceCollectionViewCell heightPerIntroduceElementLine] * [_goods linesForMultiIntroduce];
		}
	}
	return CGSizeMake(width, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	Class class = _sectionClasses[indexPath.section];
	NSString *identifier = @"Header";
	UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
	if (class == [MLGoodsCollectionViewCell class]) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(ML_COMMON_EDGE_LEFT, 5, collectionView.bounds.size.width - ML_COMMON_EDGE_LEFT - ML_COMMON_EDGE_RIGHT, 40)];
		
		//if (!_headerLabel) {
//			label = [[UILabel alloc] initWithFrame:CGRectMake(minimumInteritemSpacing, 5, collectionView.bounds.size.width - 2 * minimumInteritemSpacing, view.bounds.size.height)];
			label.text = @"猜你喜欢";
			label.font = [UIFont systemFontOfSize:16];
			label.textColor = [UIColor fontGrayColor];
			//[view addSubview:_headerLabel];
		[view addSubview:label];
		//}
	}
	return view;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	Class class = _sectionClasses[section];
	if (class == [MLGoodsCollectionViewCell class]) {
		NSInteger numberPerLine = 2;
		CGFloat itemWidth = [class size].width;
		CGFloat gap = [NSNumber edgeWithMaxWidth:collectionView.bounds.size.width itemWidth:itemWidth numberPerLine:numberPerLine].floatValue;
		return UIEdgeInsetsMake(10, gap, 10, gap);
	}
	return UIEdgeInsetsZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	Class class = _sectionClasses[section];
	if (class == [MLGoodsCollectionViewCell class]) {
		return _relatedMultiGoods.count;
	}
	return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return _sectionClasses.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	Class class = _sectionClasses[indexPath.section];
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[class identifier] forIndexPath:indexPath];
	cell.backgroundColor = [UIColor whiteColor];
	if (class == [MLGalleryCollectionViewCell class]) {
		MLGalleryCollectionViewCell	*galleryCell = (MLGalleryCollectionViewCell *)cell;
		galleryCell.imagePaths = _goods.gallery;
	} else if (class == [MLGoodsInfoCollectionViewCell class]) {
		MLGoodsInfoCollectionViewCell *infoCell = (MLGoodsInfoCollectionViewCell *)cell;
		infoCell.goods = _goods;
		infoCell.delegate = self;
	} else  if (class == [MLCommonCollectionViewCell class]) {
		MLCommonCollectionViewCell *commonCell = (MLCommonCollectionViewCell *)cell;
		if (indexPath.section == 2) {
			commonCell.text = [NSString stringWithFormat:@"选择:%@", _goods.choose ?: @""];
		} else if (indexPath.section == 3) {
			commonCell.text = @"图文详情";
			commonCell.image = [UIImage imageNamed:@"ImagesDetails"];
		} else if (indexPath.section == 5) {
			NSString *text = [NSString stringWithFormat:@"累计评价(%@)", _goods.commentsNumber];
			NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
			[attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor themeColor] range:NSMakeRange(4, text.length - 4)];
			commonCell.attributedText = attributedString;
			commonCell.image = [UIImage imageNamed:@"Like"];
		}
	} else if (class == [MLGoodsIntroduceCollectionViewCell class]) {
		MLGoodsIntroduceCollectionViewCell *introduceCell = (MLGoodsIntroduceCollectionViewCell *)cell;
		introduceCell.text = @"参数规格";
		introduceCell.image = [UIImage imageNamed:@"Parameters"];
		if (_showIndroduce){
			[introduceCell.contentView addSubview:_introduceView];
		} else {
			[_introduceView removeFromSuperview];
		}
	} else if (class == [MLFlagStoreCollectionViewCell class]) {
		MLFlagStoreCollectionViewCell *flagStoreCell = (MLFlagStoreCollectionViewCell *)cell;
		[flagStoreCell.imageView setImageWithURL:[NSURL URLWithString:_flagshipStore.imagePath]];
		flagStoreCell.text = _flagshipStore.name;
	} else if (class == [MLVoucherCollectionViewCell class]) {
		MLVoucherCollectionViewCell *voucherCell = (MLVoucherCollectionViewCell *)cell;
		voucherCell.voucher = _voucher;
		voucherCell.backgroundColor = [UIColor clearColor];
	} else if (class == [MLGoodsCollectionViewCell class]) {
		MLGoods *goods = _relatedMultiGoods[indexPath.row];
		MLGoodsCollectionViewCell *goodsCell = (MLGoodsCollectionViewCell *)cell;
		goodsCell.goods = goods;
	}
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.tabBarController.tabBar.hidden) {
		[self hideAddCartView:YES];
		return;
	}
	Class class = _sectionClasses[indexPath.section];
	if (class == [MLGoodsIntroduceCollectionViewCell class]) {
		_showIndroduce = !_showIndroduce;
		[_collectionView reloadData];
	} else if (class == [MLCommonCollectionViewCell class]) {
		if (indexPath.section == 2) {//选择
			[self.viewDeckController toggleRightView];
			//[self showPropertiesView];
		} else if (indexPath.section == 3) {//图文详情
			MLGoodsImagesDetailsViewController *imagesDetailsViewController = [[MLGoodsImagesDetailsViewController alloc] initWithNibName:nil bundle:nil];
			imagesDetailsViewController.goods = _goods;
			imagesDetailsViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:imagesDetailsViewController animated:YES];
		}
	} else if (class == [MLFlagStoreCollectionViewCell class]) {
		MLFlagshipStoreViewController *flagshipStoreViewController = [[MLFlagshipStoreViewController alloc] initWithNibName:nil bundle:nil];
		flagshipStoreViewController.flagshipStore = _flagshipStore;
		flagshipStoreViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:flagshipStoreViewController animated:YES];
	} else if (class == [MLGoodsCollectionViewCell class]) {
		MLGoods *goods = _relatedMultiGoods[indexPath.row];
		MLGoodsDetailsViewController *goodsDetailsViewController = [[MLGoodsDetailsViewController alloc] initWithNibName:nil bundle:nil];
		NSLog(@"goods: %@", goods);
		goodsDetailsViewController.goods = goods;
		[self.navigationController pushViewController:goodsDetailsViewController animated:YES];
	}
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
	Class class = _sectionClasses[indexPath.section];
	if (class == [MLGoodsIntroduceCollectionViewCell class]) {
		_showIndroduce = !_showIndroduce;
		[_collectionView reloadData];
	}
}


@end
