//
//  RTUnitLayoutAttributes.h
//  Convert All Units
//
//  Created by Aleksandar Vacić on 1.10.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTUnitLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic) CGFloat screenViewCenterOffset;
@property (nonatomic) BOOL numberValueSwitched;
@property (nonatomic) BOOL isSource;
@property (nonatomic) BOOL leftAligned;

@end
