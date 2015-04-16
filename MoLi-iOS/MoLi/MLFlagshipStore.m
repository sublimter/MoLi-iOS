//
//  MLFlagshipStore.m
//  MoLi
//
//  Created by zhangbin on 12/16/14.
//  Copyright (c) 2014 zoombin. All rights reserved.
//

#import "MLFlagshipStore.h"

@implementation MLFlagshipStore

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
	self = [super initWithAttributes:attributes];
	if (self) {
		_ID = [attributes[@"storeid"] notNull];
		_iconPath = [attributes[@"storeimage"] notNull];
		_name = [attributes[@"storename"] notNull];
		_imagePath = [attributes[@"businessimage"] notNull];
		_favorites = [attributes[@"favorites"] notNull];
		
		//商品详情界面返回的数据错了，应该是返回旗舰店的key，但是返回的实体店的key，服务器问题
		if (!_ID && [attributes[@"businessid"] notNull]) {
			_ID = [attributes[@"businessid"] notNull];
		}
		
		if (!_iconPath && [attributes[@"businessicon"] notNull]) {
			_iconPath = [attributes[@"businessicon"] notNull];
		}
		
		if (!_name && [attributes[@"businessname"] notNull]) {
			_name = [attributes[@"businessname"] notNull];
		}
	}
	return self;
}

@end
