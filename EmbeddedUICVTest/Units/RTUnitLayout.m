//
//  RTUnitLayout.m
//  Convert All Units
//
//  Created by Aleksandar Vacić on 28.9.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import "RTUnitLayout.h"
#import "RTUnitLayoutAttributes.h"


NSString *const RTUNITCELL = @"RTUNIT_CELL";
NSString *const RTUnitLayoutElementCell = @"RTUnitLayoutElementCell";


@interface RTUnitLayout ()

@property (nonatomic) CGFloat ACTIVE_DISTANCE;

@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic) CGSize contentSize;

@property (nonatomic) BOOL shouldRecalculateLayout;
@property (nonatomic, strong) NSDictionary *cachedLayoutInfo;
@property (nonatomic) CGRect cachedBounds;
@property (nonatomic) CGRect cachedLayoutBounds;

@end

@implementation RTUnitLayout

- (instancetype)init {
	
	self = [super init];
	if (!self) return nil;
	
	[self commonInit];
	
	return self;
}

- (void)awakeFromNib {
	
	[self commonInit];
}

- (void)commonInit {
	
	_scrollDirection = UICollectionViewScrollDirectionVertical;
	
	_itemSize = CGSizeMake(160, 98);	//	this is minimal value. actual will be computed as requested
	_leftAligned = YES;
	_numberValueSwitched = NO;
	_isSource = YES;
	
	[self applyTheme:nil];
	_minimumInteritemSpacing = 0.0;
	_minimumLineSpacing = 0.0;
	_sectionInset = UIEdgeInsetsZero;
	
	_ACTIVE_DISTANCE = self.itemSize.height;
	
	_shouldRecalculateLayout = YES;
	self.layoutInfo = nil;
	self.cachedLayoutInfo = nil;
	_cachedLayoutBounds = CGRectZero;
	_cachedBounds = CGRectZero;
}

#pragma mark

- (void)calculateTotalContentSize {
	
	__block CGRect f = CGRectNull;
	
	NSDictionary *itemLayouts = self.layoutInfo[RTUnitLayoutElementCell];
	[itemLayouts enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
		CGRect frame = attributes.frame;
		f = CGRectUnion(f, frame);
	}];
	
	CGSize cs = f.size;
	self.contentSize = cs;
}

- (CGSize)collectionViewContentSize {
	
	CGSize cs = self.contentSize;
	return cs;
}

#pragma mark

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	
	self.shouldRecalculateLayout = self.shouldRecalculateLayout ||
									(CGRectGetWidth(newBounds) != CGRectGetWidth(self.collectionView.bounds) ||
									CGRectGetHeight(newBounds) != CGRectGetHeight(self.collectionView.bounds));
	NSLog(@"%@ %s : %@, %@ -> %@", (self.isSource) ? @"LEFT" : @"RIGHT", __FUNCTION__, @(self.shouldRecalculateLayout), NSStringFromCGRect(self.collectionView.bounds), NSStringFromCGRect(newBounds));

	return YES;
}

- (void)prepareLayout {
	[super prepareLayout];
	
	CGRect currentBounds = self.collectionView.bounds;
	
	if (self.shouldRecalculateLayout || !self.layoutInfo) {
		
		self.cachedLayoutBounds = self.cachedBounds;
		
		//	make sure itemsize is always full width
		CGSize itemSize = self.itemSize;
		itemSize.width = CGRectGetWidth(currentBounds);
		self.itemSize = itemSize;
		self.ACTIVE_DISTANCE = self.itemSize.height;
		
		NSLog(@"%@ %s, bounds=%@, itemsize=%@", (self.leftAligned) ? @"LEFT" : @"RIGHT", __FUNCTION__, NSStringFromCGRect(currentBounds), NSStringFromCGSize(itemSize));

		//	cache (possibly) existing layout info, to be used during CV updates
		if (self.layoutInfo) {
			self.cachedLayoutInfo = [[NSDictionary alloc] initWithDictionary:self.layoutInfo copyItems:YES];
		}
		
		//	calculate new layout
		NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
		
		NSInteger sectionCount = [self.collectionView numberOfSections];
		for (NSInteger section = 0; section < sectionCount; section++) {
			NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
			if (itemCount > 0) {
				NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
				for (NSInteger item = 0; item < itemCount; item++) {
					NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
					
					RTUnitLayoutAttributes *attr = [RTUnitLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
					attr.frame = [self calculateItemFrameForAttributes:attr];
					[self applyAttributes:attr viewport:currentBounds];
					
					cellLayoutInfo[indexPath] = attr;
				}
				newLayoutInfo[RTUnitLayoutElementCell] = cellLayoutInfo;
			}
		}
		self.layoutInfo = newLayoutInfo;
		
		//	calculate total size. this must be done even when bounds not changed, say due to data source change
		[self calculateTotalContentSize];
		
		self.shouldRecalculateLayout = NO;
	}
	
	self.cachedBounds = currentBounds;
}

- (CGRect)calculateItemFrameForAttributes:(UICollectionViewLayoutAttributes *)attributes {
	
	NSInteger row = attributes.indexPath.item;
	CGRect f = attributes.frame;
	f.size = self.itemSize;
	
	if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
		f.origin.x = self.sectionInset.left + row * (self.itemSize.width + self.minimumLineSpacing);
		f.origin.y = self.sectionInset.top;
	} else {
		f.origin.x = self.sectionInset.left;
		f.origin.y = self.sectionInset.top + row * (self.itemSize.height + self.minimumLineSpacing);
	}
	
	return f;
}

#pragma mark - Layout Attributes

+ (Class)layoutAttributesClass {
	
	return [RTUnitLayoutAttributes class];
}

- (void)applyAttributes:(RTUnitLayoutAttributes *)attributes viewport:(CGRect)visibleRect {
	
	attributes.numberValueSwitched = self.numberValueSwitched;
	attributes.isSource = self.isSource;
	attributes.leftAligned = self.leftAligned;
	
	[self setLineAttributes:attributes visibleRect:visibleRect];
}

- (void)setLineAttributes:(RTUnitLayoutAttributes *)attributes visibleRect:(CGRect)visibleRect {
	
	if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
		CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
		attributes.screenViewCenterOffset = distance;
		
	} else {
		CGFloat distance = CGRectGetMidY(visibleRect) - attributes.center.y;
		attributes.screenViewCenterOffset = distance;
	}
}

#pragma mark

- (RTUnitLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	RTUnitLayoutAttributes *attr = [self.layoutInfo[RTUnitLayoutElementCell][indexPath] copy];
	[self applyAttributes:attr viewport:self.collectionView.bounds];
	
//	if (!self.leftAligned) NSLog(@"%s : %@ frame=%@", __FUNCTION__, indexPath, NSStringFromCGRect(attr.frame));
	return attr;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	
//	if (!self.leftAligned) NSLog(@"%s : rect=%@", __FUNCTION__, NSStringFromCGRect(rect));

	NSMutableArray *arr = [NSMutableArray array];
	[self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *kind,
														 NSDictionary *cellLayoutInfo,
														 BOOL *stop) {
		[cellLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
															UICollectionViewLayoutAttributes *attr,
															BOOL *innerStop) {
			if (CGRectIntersectsRect(rect, attr.frame)) {
				NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:attr.indexPath.section];
				if (attr.indexPath.item >= numberOfItems) return;
				
				RTUnitLayoutAttributes *appliedAttributes = [attr copy];
				[self applyAttributes:appliedAttributes viewport:self.collectionView.bounds];
				[arr addObject:appliedAttributes];
//				if (!self.leftAligned) NSLog(@"%s : %@ frame=%@", __FUNCTION__, indexPath, NSStringFromCGRect(appliedAttributes.frame));
			}
		}];
	}];
	
	return arr;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
	//	velocity.y > 0 == down
	//	velocity.y < 0 == up
	//	velocity.x < 0 == going left
	//	velocity.x > 0 == going right
	
	CGPoint offset = proposedContentOffset;
	
	CGFloat offsetAdjustment = MAXFLOAT;
	
	if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
		CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
		
		CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
		NSArray *arr = [self layoutAttributesForElementsInRect:targetRect];
		
		for (UICollectionViewLayoutAttributes  *attr in arr) {
			if (attr.representedElementCategory != UICollectionElementCategoryCell)
				continue; // skip headers
			
			CGFloat itemHorizontalCenter = attr.center.x;
			if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
				offsetAdjustment = itemHorizontalCenter - horizontalCenter;
			}
		}
		offset.x += offsetAdjustment;
		
	} else {
		CGFloat verticalCenter = proposedContentOffset.y + (CGRectGetHeight(self.collectionView.bounds) / 2.0);
		
		CGRect targetRect = CGRectMake(0.0, proposedContentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
		NSArray *arr = [self layoutAttributesForElementsInRect:targetRect];
		
		for (UICollectionViewLayoutAttributes  *attr in arr) {
			if (attr.representedElementCategory != UICollectionElementCategoryCell)
				continue; // skip headers
			
			CGFloat itemVerticalCenter = attr.center.y;
			if (ABS(itemVerticalCenter - verticalCenter) < ABS(offsetAdjustment)) {
				offsetAdjustment = itemVerticalCenter - verticalCenter;
			}
		}
		offset.y += offsetAdjustment;
	}
	
	return offset;
}

#pragma mark - Animations

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds {

	[[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell *cell, NSUInteger idx, BOOL *stop) {
		[cell.contentView invalidateIntrinsicContentSize];
		[cell setNeedsLayout];
	}];

//	if (!self.leftAligned) NSLog(@"%s : %@ -> %@", __FUNCTION__, NSStringFromCGRect(oldBounds), NSStringFromCGRect(self.collectionView.bounds));
	[super prepareForAnimatedBoundsChange:oldBounds];
}

- (void)finalizeAnimatedBoundsChange {

//	if (!self.leftAligned) NSLog(@"%s : %@", __FUNCTION__, NSStringFromCGRect(self.collectionView.bounds));
	[super finalizeAnimatedBoundsChange];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	
	RTUnitLayoutAttributes *attr = [self.layoutInfo[RTUnitLayoutElementCell][itemIndexPath] copy];
	[self applyAttributes:attr viewport:self.collectionView.bounds];
	
//	if (!self.leftAligned) NSLog(@"%s : %@ frame=%@", __FUNCTION__, itemIndexPath, NSStringFromCGRect(attr.frame));
	return attr;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	
	RTUnitLayoutAttributes *attr = [self.cachedLayoutInfo[RTUnitLayoutElementCell][itemIndexPath] copy];
	[self applyAttributes:attr viewport:self.cachedLayoutBounds];
	
//	if (!self.leftAligned) NSLog(@"%s : %@ frame=%@", __FUNCTION__, itemIndexPath, NSStringFromCGRect(attr.frame));
	return attr;
}

#pragma mark - Extras

- (NSIndexPath *)indexPathForOffset:(CGPoint)offset {
	
	__block NSIndexPath *indexPath = nil;
	CGPoint center = self.collectionView.center;
	center.x += offset.x;
	center.y += offset.y;
	
	[(NSDictionary *)self.layoutInfo[RTUnitLayoutElementCell] enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, RTUnitLayoutAttributes *attr, BOOL *stop) {
		if (CGRectContainsPoint(attr.frame, center)) {
			*stop = YES;
			indexPath = key;
		}
	}];
	
	return indexPath;
}

- (void)applyTheme:(NSNotification *)notification {
	
	CGSize is = self.itemSize;
	is.height = 90;
	self.itemSize = is;
	self.ACTIVE_DISTANCE = self.itemSize.height;
	
	self.shouldRecalculateLayout = YES;
	
	[self invalidateLayout];
}

- (void)forceLayoutRecalculation {
	
	self.shouldRecalculateLayout = YES;
	[self invalidateLayout];
}

@end