//
//  RTUnitCell.h
//  Convert All Units
//
//  Created by Aleksandar Vacić on 28.9.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTUnitCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (nonatomic) CGFloat screenViewCenterOffset;
@property (nonatomic) BOOL numberValueSwitched;
@property (nonatomic) BOOL leftAligned;
@property (nonatomic) BOOL isSource;

@end

