//
//  MLAfterSalePromblemDescCell.m
//  MoLi
//
//  Created by LLToo on 15/4/14.
//  Copyright (c) 2015年 zoombin. All rights reserved.
//

#import "MLAfterSalePromblemDescCell.h"
#import "MLCache.h"

@interface MLAfterSalePromblemDescCell()

@property (nonatomic,weak)  UILabel *lblProDesc;        //问题描述


@end

@implementation MLAfterSalePromblemDescCell

+ (CGFloat)height:(BOOL)isBremark{
    //是否有卖家反馈
    if (isBremark) {
        return 115;
    }
    else {
        return 80;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}


- (void)setAfterSaleGoodsDetailDict:(NSDictionary *)dict
{
    _afterSaleGoodsDetailDict = dict;
    
    
    //        CGFloat fullWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat leftWidth = 65;
    CGFloat offsetY = 75;
    CGFloat rightWidth = 200;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(5, 15, 10, 15);
    CGRect rect = CGRectZero;
    rect.origin.x = edgeInsets.left;
    rect.size.height = 28;
    rect.origin.y = edgeInsets.top;
    rect.size.width = leftWidth;
    
    UILabel *leftTitleLbl = [MLAfterSalePromblemDescCell leftTitleLabel:@"问题描述:"];
    leftTitleLbl.frame = rect;
    [self.contentView addSubview:leftTitleLbl];
    
    rect.origin.x = rect.origin.y+offsetY;
    rect.size.width = rightWidth;
    _lblProDesc = [MLAfterSalePromblemDescCell rightTitleLabel];
    _lblProDesc.frame = rect;
    _lblProDesc.text = [[dict objectForKey:@"service"] objectForKey:@"uremark"];
    [self.contentView addSubview:_lblProDesc];
    
    NSString *bremark = [[dict objectForKey:@"service"] objectForKey:@"bremark"];
    if(![MLCache isNullObject:bremark]) {
        rect.origin.y += 28;
        rect.origin.x = edgeInsets.left;
        rect.size.width = leftWidth;
        
        leftTitleLbl = [MLAfterSalePromblemDescCell leftTitleLabel:@"商家备注:"];
        leftTitleLbl.frame = rect;
        [self.contentView addSubview:leftTitleLbl];
        
        rect.origin.x = rect.origin.x+offsetY;
        rect.size.width = rightWidth;
        UILabel *bremarkLbl = [MLAfterSalePromblemDescCell rightTitleLabel];
        bremarkLbl.frame = rect;
        bremarkLbl.text = bremark;
        [self.contentView addSubview:bremarkLbl];
    }
    
    
    rect.origin.y += 28;
    rect.origin.x = edgeInsets.left;
    rect.size.width = leftWidth;
    
    leftTitleLbl = [MLAfterSalePromblemDescCell leftTitleLabel:@"图片凭证:"];
    leftTitleLbl.frame = rect;
    [self.contentView addSubview:leftTitleLbl];
    
    CGRect imgRect = CGRectMake(rect.origin.x+offsetY, rect.origin.y, 15, 15);
    
    NSArray *arrImgs = [[dict objectForKey:@"service"] objectForKey:@"images"];
    if(arrImgs) {
        for (NSString *imgStr in arrImgs) {
            UIImageView *imgview = [[UIImageView alloc] initWithFrame:imgRect];
            [imgview setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"Avatar"]];
            [self.contentView addSubview:imgview];
            
            imgRect.origin.y += 20;
        }
    }
    
    // 添加锯齿
    UIImageView *cornerLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cornerline"]];
    cornerLineView.frame = CGRectMake(0, 80-cornerLineView.frame.size.height, WINSIZE.width, cornerLineView.frame.size.height);
    [self addSubview:cornerLineView];
}


+ (UILabel *)leftTitleLabel:(NSString *)title
{
    UILabel *leftTitleLbl =[[UILabel alloc] init];
    leftTitleLbl.textAlignment = NSTextAlignmentLeft;
    leftTitleLbl.textColor = [UIColor blackColor];
    leftTitleLbl.font = [UIFont systemFontOfSize:14];
    leftTitleLbl.text = title;
    return leftTitleLbl;
}

+ (UILabel *)rightTitleLabel
{
    UILabel *leftTitleLbl =[[UILabel alloc] init];
    leftTitleLbl.textAlignment = NSTextAlignmentLeft;
    leftTitleLbl.textColor = [UIColor darkGrayColor];
    leftTitleLbl.font = [UIFont systemFontOfSize:14];
    return leftTitleLbl;
}

@end
