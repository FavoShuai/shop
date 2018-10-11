//
//  CreateAdressVC.h
//  Shopping
//
//  Created by apple on 2018/7/13.
//  Copyright © 2018年 啊湫. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, AdressType) {
    AdressType_Edit,
    AdressType_Create,
};

@interface CreateAdressVC : BaseViewController
@property (nonatomic , assign) AdressType type;
@end
