//
//  RTUnitViewController.m
//  Convert All Units
//
//  Created by Aleksandar Vacić on 28.9.13..
//  Copyright (c) 2013. Radiant Tap. All rights reserved.
//

#import "RTUnitViewController.h"
#import "RTUnitLayout.h"
#import "RTUnitCell.h"
#import "RTUnitCell+RTUnit.h"
#import "RTUnitLayoutAttributes.h"

@interface RTUnitViewController () < UIScrollViewDelegate >

@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, getter = isUserScrolling) BOOL userScrolling;

@end

@implementation RTUnitViewController

#pragma mark - Init

- (instancetype)init {
	
	RTUnitLayout *l = [[RTUnitLayout alloc] init];
	self = [super initWithCollectionViewLayout:l];
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
	
	self = [super initWithCollectionViewLayout:layout];
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (void)commonInit {

	self.automaticallyAdjustsScrollViewInsets = NO;

	_userScrolling = NO;
	_targetController = NO;
	_leftController = YES;
}



#pragma mark -

- (void)applyTheme:(NSNotification *)notification {

	//	setup contentInset
	[self setupContentInset:self.collectionView.bounds.size];
	
	if (notification) {
		RTUnitLayout *l = (RTUnitLayout *)self.collectionView.collectionViewLayout;
		[l applyTheme:notification];
		
		[self.collectionView reloadData];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self processCustomScrollRestoreAnimated:NO];
		});
	}
}

- (void)refreshData {

	self.currentIndexPath = nil;

	[self.collectionView.collectionViewLayout invalidateLayout];
	[self.collectionView reloadData];

	//	scroll to preselected unit
	[self processCustomStateRestore];
	[self processCustomScrollRestoreAnimated:YES];
}

- (void)setTargetController:(BOOL)targetController {

//	if (_targetController == targetController) return;
	_targetController = targetController;
	
	if (!targetController) {
		[self refreshData];
	} else {
		//	target column will be reset during subsequent conversion call
	}
}

#pragma mark - View lifecycle

- (void)setupContentInset:(CGSize)size {
	
	CGFloat itemHeight = 90;
	UIEdgeInsets oldContentInset = self.collectionView.contentInset;
	
	UIEdgeInsets contentInset = oldContentInset;
	contentInset.top = (size.height - itemHeight) / 2.0;
	contentInset.bottom = contentInset.top;
	
	self.collectionView.contentInset = contentInset;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.collectionView registerNib:[UINib nibWithNibName:@"RTUnitCell" bundle:nil] forCellWithReuseIdentifier:RTUNITCELL];
	self.collectionView.alwaysBounceVertical = YES;
	self.collectionView.showsVerticalScrollIndicator = NO;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.scrollsToTop = YES;
	self.collectionView.backgroundColor = (self.isLeftController) ? [UIColor grayColor] : [UIColor lightGrayColor];
	
	RTUnitLayout *l = (RTUnitLayout *)self.collectionView.collectionViewLayout;
	l.leftAligned = self.leftController;
	l.isSource = !self.targetController;
	
	[self applyTheme:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	//	scroll to preselected unit
	[self processCustomStateRestore];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self processCustomScrollRestoreAnimated:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	if (coordinator) {
		[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

		} completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
			[self setupContentInset:size];
			[self processCustomScrollRestoreAnimated:NO];
		}];

	} else {
		[self setupContentInset:size];
		[self processCustomScrollRestoreAnimated:NO];
	}
}

#pragma mark

- (void)processCustomScrollRestoreAnimated:(BOOL)animated {
	
	if (!self.currentIndexPath) {
		return;
	}
	UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:self.currentIndexPath];
	CGPoint contentOffset = self.collectionView.contentOffset;
	CGFloat verticalCenter = CGRectGetHeight(self.collectionView.bounds) / 2.0;
	contentOffset.y = attr.center.y - verticalCenter;
	
	[self.collectionView setContentOffset:contentOffset animated:animated];
}

- (void)processCustomStateRestore {
	
	NSIndexPath *indexPath = [self preselectedIndexPath];
	if (!indexPath) return;
	self.currentIndexPath = indexPath;
}

- (NSIndexPath *)preselectedIndexPath {

	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.isLeftController) ? 1 : 10 inSection:0];
	return indexPath;
}


#pragma mark - UICollectionVIew

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 11;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    RTUnitCell *cell = (RTUnitCell *)[collectionView dequeueReusableCellWithReuseIdentifier:RTUNITCELL forIndexPath:indexPath];
	[cell populateWithUnit:nil value:[NSString stringWithFormat:@"1%@.34", @(pow(indexPath.item, 2.0))]];

    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	return collectionView.scrollEnabled && !self.userScrolling;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	self.currentIndexPath = indexPath;

	UICollectionViewLayoutAttributes *attr = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
	CGPoint contentOffset = collectionView.contentOffset;
	CGFloat verticalCenter = CGRectGetHeight(collectionView.bounds) / 2.0;
	contentOffset.y = attr.center.y - verticalCenter;
	[collectionView setContentOffset:contentOffset animated:YES];
}



#pragma mark - Scroll view

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	self.userScrolling = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

	[self processScrollingEnd:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	[self processScrollingEnd:scrollView];
}

- (void)processScrollingEnd:(UIScrollView *)scrollView {
	
	if (!self.userScrolling) return;
	self.userScrolling = NO;
	
	//	find indexPath of the item where scrolling stopped
	RTUnitLayout *l = (RTUnitLayout *)self.collectionViewLayout;
	CGPoint offset = scrollView.contentOffset;
	NSIndexPath *indexPath = [l indexPathForOffset:offset];
	if (!indexPath) return;
	if (indexPath.item == NSNotFound) return;
	self.currentIndexPath = indexPath;
}

@end
