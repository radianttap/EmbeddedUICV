//
//  RTUnitLayoutAttributes.m
//  Convert All Units
//
//  Created by Aleksandar Vacić on 1.10.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import "RTUnitLayoutAttributes.h"

@implementation RTUnitLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
	
	RTUnitLayoutAttributes *attributes = [super copyWithZone:zone];
	attributes.screenViewCenterOffset = self.screenViewCenterOffset;
	attributes.numberValueSwitched = self.numberValueSwitched;
	attributes.isSource = self.isSource;
	attributes.leftAligned = self.leftAligned;
	
	return attributes;
}

- (BOOL)isEqual:(id)other {
	if (other == self) {
		return YES;
	}
	if (!other || ![[other class] isEqual:[self class]]) {
		return NO;
	}
	if ([((RTUnitLayoutAttributes *) other) screenViewCenterOffset] != [self screenViewCenterOffset]) {
		return NO;
	}
	if ([((RTUnitLayoutAttributes *) other) numberValueSwitched] != [self numberValueSwitched]) {
		return NO;
	}
	if ([((RTUnitLayoutAttributes *) other) isSource] != [self isSource]) {
		return NO;
	}
	if ([((RTUnitLayoutAttributes *) other) leftAligned] != [self leftAligned]) {
		return NO;
	}
	
	return [super isEqual:other];
}

@end
