// 
//  MasonryEqualToSuperviewExample.m
//  Masonry
//
//  Example showing how to use the new equalToSuperview method
//  Similar to SnapKit's snp.equalToSuperview() API
//

#import "Masonry.h"

// Example 1: Single attribute equal to superview
void example1() {
    UIView *containerView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    // Make childView's leading edge equal to containerView (superview)
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalToSuperview;
    }];
}

// Example 2: Multiple attributes chained to superview
void example2() {
    UIView *containerView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    // Chain multiple attributes and equal to superview
    // make.leading.top.equalToSuperview is equivalent to:
    // make.leading.equalToSuperview
    // make.top.equalToSuperview
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalToSuperview;
    }];
}

// Example 3: Multiple attributes with offset
void example3() {
    UIView *containerView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    // Equal to superview with insets
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalToSuperview.insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
}

// Example 4: Leading, top equal to superview with trailing, bottom offset
void example4() {
    UIView *containerView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalToSuperview.offset(10);
        make.trailing.bottom.equalToSuperview.offset(-10);
    }];
}

// Example 5: With UILayoutGuide
void example5() API_AVAILABLE(ios(9.0)) {
    UIView *containerView = [[UIView alloc] init];
    UILayoutGuide *layoutGuide = [[UILayoutGuide alloc] init];
    [containerView addLayoutGuide:layoutGuide];
    
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    // LayoutGuide constraints - equalToSuperview refers to layoutGuide's owningView
    [layoutGuide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalToSuperview;
    }];
}

// Example 6: Update constraints
void example6() {
    UIView *containerView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    // Initial constraints
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalToSuperview;
    }];
    
    // Update constraints later
    [childView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalToSuperview.offset(20);
    }];
}

// Example 7: Combining with other constraints
void example7() {
    UIView *containerView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalToSuperview;
        make.width.equalTo(@(100));
        make.height.equalTo(@(100));
    }];
}

// Example 8: Using with priority and multiplier
void example8() {
    UIView *containerView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalToSuperview.multipliedBy(0.5).priorityHigh;
    }];
}

// Example 9: Safe area layout guide (iOS 11+)
void example9() API_AVAILABLE(ios(11.0)) {
    UIView *containerView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    [containerView addSubview:childView];
    
    // Note: equalToSuperview on childView refers to its superview
    // For safe area, you would still use explicit view attributes
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalToSuperview;
        make.trailing.bottom.equalToSuperview;
    }];
}

// Example 10: Complex layout with mixed constraints
void example10() {
    UIView *containerView = [[UIView alloc] init];
    UIView *header = [[UIView alloc] init];
    UIView *content = [[UIView alloc] init];
    
    [containerView addSubview:header];
    [containerView addSubview:content];
    
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalToSuperview;
        make.height.equalTo(@(60));
    }];
    
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalToSuperview;
        make.top.equalTo(header.mas_bottom);
    }];
}
