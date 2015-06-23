//
//  RTUnitViewController.h
//  Convert All Units
//
//  Created by Aleksandar Vacić on 28.9.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTUnitViewController : UICollectionViewController

@property (nonatomic, getter = isTargetController) BOOL targetController;
@property (nonatomic, getter = isLeftController) BOOL leftController;

@end

