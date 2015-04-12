//
//  MLAddressesViewController.h
//  MoLi
//
//  Created by zhangbin on 12/15/14.
//  Copyright (c) 2014 zoombin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLAddressTableViewCellDelegate <NSObject>

@optional
- (void)selectedAddress:(MLAddress *)address;

@end

@interface MLAddressesViewController : UIViewController

@property (nonatomic, weak) id <MLAddressTableViewCellDelegate> delegate;
@property (nonatomic, assign) BOOL selectMode;

@end
