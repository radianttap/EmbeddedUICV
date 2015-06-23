//
//  RTUnitCell+RTUnit.m
//  Convert All Units
//
//  Created by Aleksandar Vacić on 28.9.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import "RTUnitCell+RTUnit.h"

@implementation RTUnitCell (RTUnit)

- (void)populateWithUnit:(id)unit value:(NSString *)value {

	self.numberLabel.text = value;
	self.symbolLabel.text = @"mph";
	self.nameLabel.text = @"miles per hour";
}

@end
