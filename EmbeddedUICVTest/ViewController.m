//
//  ViewController.m
//  EmbeddedUICVTest
//
//  Created by Aleksandar Vacić on 22.6.15..
//  Copyright © 2015. Radiant Tap. All rights reserved.
//

#import "ViewController.h"
#import "RTUnitViewController.h"
#import "RTUnitLayout.h"
#import "RTUnitCell.h"
#import "RTUnitCell+RTUnit.h"

@interface ViewController ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *firstView;
@property (nonatomic, weak) UIView *secondView;
@property (nonatomic, strong) NSLayoutConstraint *contentViewEdgeConstraint;

@property (nonatomic, strong) UIView *keypadView;
@property (nonatomic, getter = shouldShowKeyboardOnAppear) BOOL showKeyboardOnAppear;
@property (nonatomic) CGFloat keypadDimension;

@property (copy, nonatomic) NSArray *constraints;

@property (nonatomic, strong) RTUnitViewController *leftColumnController;
@property (nonatomic, strong) RTUnitViewController *rightColumnController;

@end

@implementation ViewController

#pragma mark - Init

- (instancetype)init {
	
	self = [super init];
	if (!self) return nil;
	
	[self commonInit];
	
	return self;
}

- (void)commonInit {
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	_showKeyboardOnAppear = NO;
}

- (void)loadView {
	[super loadView];
	
	//	content view where children will be added
	UIView *contentView = [UIView new];
	contentView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:contentView];
	self.contentView = contentView;
	
	//	container views for each controller
	UIView *vl = [UIView new];
	vl.translatesAutoresizingMaskIntoConstraints = NO;
	vl.backgroundColor = [UIColor redColor];
	[contentView addSubview:vl];
	self.firstView = vl;
	
	UIView *vr = [UIView new];
	vr.translatesAutoresizingMaskIntoConstraints = NO;
	vr.backgroundColor = [UIColor blueColor];
	[contentView addSubview:vr];
	self.secondView = vr;
	
	{
		NSDictionary *vd = @{@"vl": vl, @"vr": vr};
		NSDictionary *metrics = nil;
		[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vl]|" options:0 metrics:metrics views:vd]];
		[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vr]|" options:0 metrics:metrics views:vd]];
		[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[vl][vr(vl)]|" options:0 metrics:metrics views:vd]];
	}
	
	//	now, also load custom keypad
	
	UIView *kvc = [[UIView alloc] init];
	kvc.backgroundColor = [UIColor orangeColor];
	kvc.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:kvc];
	self.keypadView = kvc;
	
	[self updateConstraintsForTraitCollection:self.traitCollection viewSize:self.view.bounds.size];
}

- (void)loadColumns {
	
	RTUnitViewController *lc = [[RTUnitViewController alloc] init];
	lc.leftController = YES;
	lc.targetController = NO;
	lc.view.translatesAutoresizingMaskIntoConstraints = NO;
	[self addChildViewController:lc];
	[self.firstView addSubview:lc.view];
	[lc didMoveToParentViewController:self];
	self.leftColumnController = lc;
	lc.collectionView.scrollsToTop = YES;
	
	RTUnitViewController *rc = [[RTUnitViewController alloc] init];
	rc.leftController = NO;
	rc.targetController = YES;
	rc.view.translatesAutoresizingMaskIntoConstraints = NO;
	[self addChildViewController:rc];
	[self.secondView addSubview:rc.view];
	[rc didMoveToParentViewController:self];
	self.rightColumnController = rc;
	rc.collectionView.scrollsToTop = YES;
	
	NSDictionary *vd = @{@"lcv":lc.view, @"rcv":rc.view, @"view": self.view};
	[self.firstView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[lcv]-5-|" options:0 metrics:nil views:vd]];
	[self.firstView addConstraint:[NSLayoutConstraint constraintWithItem:lc.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.firstView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.firstView addConstraint:[NSLayoutConstraint constraintWithItem:lc.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.firstView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lcv(view)]" options:0 metrics:nil views:vd]];
	
	[self.secondView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[rcv]-5-|" options:0 metrics:nil views:vd]];
	[self.secondView addConstraint:[NSLayoutConstraint constraintWithItem:rc.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.secondView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.secondView addConstraint:[NSLayoutConstraint constraintWithItem:rc.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.secondView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rcv(view)]" options:0 metrics:nil views:vd]];
	
	[self.view setNeedsLayout];
}

#pragma mark - Orientation / Size changes

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
	
	if ([container isEqual:self.leftColumnController] || [container isEqual:self.rightColumnController]) {
		CGSize size = parentSize;	//	this is returned by default
		size.width /= 2.0;
		return size;
	}
	
	return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	
	[self updateConstraintsForTraitCollection:self.splitViewController.traitCollection viewSize:size];
	
	if (coordinator) {
		[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
			[self.view layoutIfNeeded];
			[self processWorkaroundForCollectionView:self.leftColumnController.collectionView];
			[self processWorkaroundForCollectionView:self.rightColumnController.collectionView];
		} completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
			
		}];
	} else {
		[self.view layoutIfNeeded];
	}
	
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	
	[self updateConstraintsForTraitCollection:self.splitViewController.traitCollection viewSize:self.view.bounds.size];
}

- (void)updateConstraintsForTraitCollection:(UITraitCollection *)traits viewSize:(CGSize)size {
	
	NSDictionary *vd = @{@"content": self.contentView, @"keypad": self.keypadView, @"tlg": self.topLayoutGuide};
	NSDictionary *metrics = nil;
	
	NSMutableArray *newConstraints = [NSMutableArray array];
	
	//	allow side UI or not?
	//	if landscape orientation, then possibly YES
	BOOL shouldUseSideKeypad = (size.width > size.height);
	//	on iPads is always shown, at the bottom
	if (traits.horizontalSizeClass == UIUserInterfaceSizeClassRegular && traits.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
		shouldUseSideKeypad = NO;
	} else {
		//	on iPhones only when horizontalSizeClass is Regular
		if (traits.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
			shouldUseSideKeypad = NO;
		}
	}
	
	if (shouldUseSideKeypad) {
		//	all iPad orientations + iPhone 6 Plus landscape
		//	place keypad on the side, always visible, vertical orientation
		
		CGFloat keypadWidth = 184.0f;
		CGFloat keypadMargin = 10.0f;
		NSDictionary *metrics = @{@"width": @(keypadWidth), @"margin": @(keypadMargin)};
		
			[newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[content]" options:0 metrics:metrics views:vd]];
			[newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[content]|" options:0 metrics:metrics views:vd]];
			
			NSLayoutConstraint *be = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
			self.contentViewEdgeConstraint = be;
			[newConstraints addObject:be];
			
			//	position keypad on the right side of contentView
			[newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tlg][keypad]|" options:0 metrics:metrics views:vd]];
			[newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[content]-(margin)-[keypad(width)]" options:0 metrics:metrics views:vd]];
			
		if (self.shouldShowKeyboardOnAppear) {
			self.contentViewEdgeConstraint.constant = - (keypadWidth+keypadMargin);
		}
		
		self.keypadDimension = keypadWidth + keypadMargin;
		
	} else {
		// all, in portrait
		CGFloat keypadHeight = 216.0f;
		
		[newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[content]|" options:0 metrics:metrics views:vd]];
		[newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[content]" options:0 metrics:metrics views:vd]];
		
		NSLayoutConstraint *be = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
		be.priority = 950;
		self.contentViewEdgeConstraint = be;
		[newConstraints addObject:be];
		
		//	position it below the bottom edge of the contentView
		NSDictionary *metrics = @{@"height": @(keypadHeight)};
		[newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[keypad]|" options:0 metrics:metrics views:vd]];
		[newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[content][keypad(height)]" options:0 metrics:metrics views:vd]];
		
		if (self.shouldShowKeyboardOnAppear) {
			self.contentViewEdgeConstraint.constant = - keypadHeight;
		}
		
		self.keypadDimension = keypadHeight;
	}
	
	//	remove previous constraints
	if (self.constraints)
		[self.view removeConstraints:self.constraints];
	
	//	add new ones
	self.constraints = newConstraints;
	[self.view addConstraints:newConstraints];
}

- (void)updateEdgeConstraintForKeyboardAppear:(BOOL)hasAppeared {
	
	if (hasAppeared) {
		self.contentViewEdgeConstraint.constant = - self.keypadDimension;
	} else {
		self.contentViewEdgeConstraint.constant = 0;
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStylePlain target:self action:@selector(toggleKeypad:)];
	self.navigationItem.rightBarButtonItem = btn;
	
	//	keyboard is always visible on Regular/Regular (like iPad)
	if (self.splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular && self.splitViewController.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
		self.showKeyboardOnAppear = YES;
	}
	
	[self loadColumns];
	
	self.navigationItem.hidesBackButton = YES;
}

#pragma mark - Calculator keypad

- (void)toggleKeypad:(id)sender {
	
	[self processCalculatorKeypadVisible:!self.shouldShowKeyboardOnAppear];
}

- (void)processCalculatorKeypadVisible:(BOOL)isShown {
	
	[self updateEdgeConstraintForKeyboardAppear:isShown];
	
	[UIView animateWithDuration:.4
						  delay:0
		 usingSpringWithDamping:.9
		  initialSpringVelocity:20
						options:0
					 animations:^{
						 NSLog(@"%s", __FUNCTION__);
						 [self.view layoutIfNeeded];
						 [self processWorkaroundForCollectionView:self.leftColumnController.collectionView];
						 [self processWorkaroundForCollectionView:self.rightColumnController.collectionView];
					 } completion:^(BOOL finished) {
						 NSLog(@"%s : completed", __FUNCTION__);
					 }];
	
	self.showKeyboardOnAppear = isShown;
}

- (void)processWorkaroundForCollectionView:(UICollectionView *)collectionView {
	
	CGFloat width = collectionView.bounds.size.width;

	NSLog(@"%s : set cells to width=%@", __FUNCTION__, @(width));
	
	[collectionView.visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell *obj, NSUInteger idx, BOOL *stop) {
		CGRect frame = obj.frame;
		frame.size.width = width;
		obj.frame = frame;
	}];
}



@end
