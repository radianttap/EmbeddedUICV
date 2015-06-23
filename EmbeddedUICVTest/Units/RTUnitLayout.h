//
//  RTUnitLayout.h
//  Convert All Units
//
//  Created by Aleksandar Vacić on 28.9.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const RTUNITCELL;
UIKIT_EXTERN NSString *const RTUnitLayoutElementCell;

@interface RTUnitLayout : UICollectionViewLayout

@property (nonatomic) BOOL numberValueSwitched;
@property (nonatomic) BOOL isSource;
@property (nonatomic) BOOL leftAligned;

- (void)applyTheme:(NSNotification *)notification;
- (NSIndexPath *)indexPathForOffset:(CGPoint)offset;

- (void)forceLayoutRecalculation;

@end
