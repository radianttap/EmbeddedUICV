//
//  RTUnitCell.m
//  Convert All Units
//
//  Created by Aleksandar Vacić on 28.9.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import "RTUnitCell.h"
#import "RTUnitLayoutAttributes.h"
#import <CoreText/CoreText.h>

@interface RTUnitCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *symbolBottomEdgeConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *symbolHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numberHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeftEdgeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameRightEdgeConstraint;

@property (nonatomic) CGFloat defaultSymbolFontSize;
@property (nonatomic) CGFloat smallSymbolFontSize;

@property (nonatomic) CGFloat numberLabelHeight;
@property (nonatomic) CGFloat symbolLabelHeight;
@property (nonatomic) CGFloat nameLabelHeight;

@end

@implementation RTUnitCell

- (instancetype)initWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self commonInit];
}

- (void)commonInit {
	
	_numberValueSwitched = NO;
	_leftAligned = NO;
	_isSource = YES;
	_screenViewCenterOffset = CGFLOAT_MAX;

	self.symbolLabel.text = @"";
	self.nameLabel.text = @"";
	self.numberLabel.text = @"";
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	self.symbolLabel.text = @"";
	self.nameLabel.text = @"";
	self.numberLabel.text = @"";
}

#pragma mark - * * *

- (void)setLeftAligned:(BOOL)leftAligned {
	
	[self setLeftAligned:leftAligned animated:NO];
}

- (void)setLeftAligned:(BOOL)leftAligned animated:(BOOL)animated {
	
	if (_leftAligned == leftAligned) return;
	_leftAligned = leftAligned;
	
	[self processAlignment];
	[self setNeedsUpdateConstraints];
	[self setNeedsLayout];
}

- (void)processAlignment {
	
	if (self.leftAligned) {
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.symbolLabel.textAlignment = NSTextAlignmentLeft;
		self.numberLabel.textAlignment = NSTextAlignmentLeft;
	} else {
		self.nameLabel.textAlignment = NSTextAlignmentRight;
		self.symbolLabel.textAlignment = NSTextAlignmentRight;
		self.numberLabel.textAlignment = NSTextAlignmentRight;
	}
}

- (void)applyLayoutAttributes:(RTUnitLayoutAttributes *)layoutAttributes {
	
	NSLog(@"%@ %s : frame=%@", (self.leftAligned) ? @"LEFT" : @"RIGHT", __FUNCTION__, NSStringFromCGRect(layoutAttributes.frame));
	
	_screenViewCenterOffset = layoutAttributes.screenViewCenterOffset;
	_numberValueSwitched = layoutAttributes.numberValueSwitched;
	_isSource = layoutAttributes.isSource;
	_leftAligned = layoutAttributes.leftAligned;
	
	[self processAlignment];
	[self setNeedsUpdateConstraints];
	[self setNeedsLayout];
}

- (void)updateConstraints {
	
	if (self.leftAligned) {
		self.nameLeftEdgeConstraint.constant = 20.0;
		self.nameRightEdgeConstraint.constant = 0.0;
	} else {
		self.nameLeftEdgeConstraint.constant = 0.0;
		self.nameRightEdgeConstraint.constant = 20.0;
	}

	//	this is factor which determines how much the labels will be smaller
	//	1 = they are full height
	//	0 = directly under the text field OR there's a number value in there
	CGFloat actionRatio = 1;
	
	if (ABS(self.screenViewCenterOffset) < self.bounds.size.height) {
		//	cell is covered with screen view, so height of its labels should be adjusted
		actionRatio = ABS(self.screenViewCenterOffset) / self.bounds.size.height;
	}
	
			//	if this is not cell in source controller, meaning it's target but without the values
			//	then show the full size labels
			if (!self.isSource) actionRatio = 1;
			
			self.symbolBottomEdgeConstraint.constant = self.symbolLabelHeight/10.0 * actionRatio;
			self.symbolHeightConstraint.constant = self.symbolLabelHeight + (self.numberLabelHeight - self.symbolLabelHeight) * actionRatio;
			CGFloat fontSize = (_smallSymbolFontSize + (_defaultSymbolFontSize - _smallSymbolFontSize)*actionRatio);
			self.symbolLabel.font = [self.symbolLabel.font fontWithSize:fontSize];
	
	[super updateConstraints];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	NSLog(@"%@ %s : %@", (self.leftAligned) ? @"LEFT" : @"RIGHT", __FUNCTION__, NSStringFromCGRect(self.frame));
}

#pragma mark - Theming

- (void)themeNameLabel:(UILabel *)label {
	
	if (!label) return;
	
	label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
	label.textColor = [UIColor darkGrayColor];
	
	self.nameLabelHeight = 20;
	self.nameHeightConstraint.constant = self.nameLabelHeight;
}

- (void)themeSymbolLabel:(UILabel *)label {
	
	if (!label) return;
	
	label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	label.textColor = [UIColor blackColor];

	self.symbolLabelHeight = 30;
	self.symbolHeightConstraint.constant = self.symbolLabelHeight;

	self.smallSymbolFontSize = label.font.pointSize;
}

- (void)themeNumberLabel:(UILabel *)label {
	
	if (!label) return;
	
	label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	label.textColor = [UIColor blackColor];

	self.numberLabelHeight = 30;
	self.numberHeightConstraint.constant = self.numberLabelHeight;

	self.defaultSymbolFontSize = label.font.pointSize;
}

@end
