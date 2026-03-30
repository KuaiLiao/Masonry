# Masonry Superview 快捷约束实现说明

## 概述
为 Masonry 添加了 3 个 superview 快捷属性，参考了 SnapKit 的 API 设计。这允许开发者以链式调用方式将约束与 superview 关联，支持单个或多个属性的组合。

## 主要特性
- ✅ 支持链式调用: `make.leading.top.equalToSuperview`
- ✅ 支持不等关系: `greaterThanOrEqualToSuperview`、`lessThanOrEqualToSuperview`
- ✅ 支持 UIView 和 UILayoutGuide
- ✅ 兼容所有现有的 Masonry 方法（offset、inset、priority 等）
- ✅ 自动获取并处理 superview

## 实现改动

### 1. MASConstraint.h
添加了 superview 快捷属性：
```objc
/**
 *	Sets the constraint relation to NSLayoutRelationEqual with the superview
 *  This is equivalent to equalTo(self.superview)
 */
@property (nonatomic, readonly) MASConstraint *equalToSuperview;
@property (nonatomic, readonly) MASConstraint *greaterThanOrEqualToSuperview;
@property (nonatomic, readonly) MASConstraint *lessThanOrEqualToSuperview;
```

### 2. MASConstraint+Private.h
添加了抽象方法声明：
```objc
/**
 *	Returns the superview of the constraint's view/layoutGuide
 *  Should return the superview for the first item in the constraint
 */
- (id)mas_superview;
```

### 3. MASConstraint.m
实现了 3 个 superview 快捷属性：
```objc
- (MASConstraint *)equalToSuperview {
    id superview = [self mas_superview];
    NSAssert(superview != nil, @"equalToSuperview requires the constrained item to have a superview.");
    return self.equalToWithRelation(superview, NSLayoutRelationEqual);
}

- (MASConstraint *)greaterThanOrEqualToSuperview {
    id superview = [self mas_superview];
    NSAssert(superview != nil, @"greaterThanOrEqualToSuperview requires the constrained item to have a superview.");
    return self.equalToWithRelation(superview, NSLayoutRelationGreaterThanOrEqual);
}

- (MASConstraint *)lessThanOrEqualToSuperview {
    id superview = [self mas_superview];
    NSAssert(superview != nil, @"lessThanOrEqualToSuperview requires the constrained item to have a superview.");
    return self.equalToWithRelation(superview, NSLayoutRelationLessThanOrEqual);
}
```

同时在抽象基类中为 `mas_superview` 提供了 `MASMethodNotImplemented()` 兜底，避免子类遗漏实现时静默失败。

### 4. MASViewConstraint.m
实现了 `mas_superview` 方法：
```objc
- (id)mas_superview {
    id item = self.firstViewAttribute.item;
    if ([item isKindOfClass:MASLayoutGuide.class]) {
        return ((MASLayoutGuide *)item).owningView;
    }
    return self.firstViewAttribute.view.superview;
}
```

### 5. MASCompositeConstraint.m
为组合约束重写 superview 快捷属性，逐个子约束分发：
```objc
- (MASConstraint *)equalToSuperview {
    for (MASConstraint *constraint in self.childConstraints.copy) {
        [constraint equalToSuperview];
    }
    return self;
}

- (MASConstraint *)greaterThanOrEqualToSuperview {
    for (MASConstraint *constraint in self.childConstraints.copy) {
        [constraint greaterThanOrEqualToSuperview];
    }
    return self;
}

- (MASConstraint *)lessThanOrEqualToSuperview {
    for (MASConstraint *constraint in self.childConstraints.copy) {
        [constraint lessThanOrEqualToSuperview];
    }
    return self;
}
```

## 使用示例

### 基础用法
```objc
UIView *containerView = [[UIView alloc] init];
UIView *childView = [[UIView alloc] init];
[containerView addSubview:childView];

// 让 childView 的 leading 和 top 与 superview 对齐
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.top.equalToSuperview;
}];
```

### 与其他方法组合
```objc
// 使用 inset 添加内边距
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalToSuperview.insets(UIEdgeInsetsMake(10, 10, 10, 10));
}];

// 使用 offset
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.top.equalToSuperview.offset(10);
    make.trailing.bottom.equalToSuperview.offset(-10);
}];

// 使用 multipliedBy 和 priority
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.equalToSuperview.multipliedBy(0.5).priorityHigh;
}];

// 不等关系
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.greaterThanOrEqualToSuperview.offset(10);
    make.bottom.lessThanOrEqualToSuperview.offset(-10);
}];
```

### 使用 UILayoutGuide
```objc
UIView *containerView = [[UIView alloc] init];
UILayoutGuide *layoutGuide = [[UILayoutGuide alloc] init];
[containerView addLayoutGuide:layoutGuide];

// LayoutGuide 的 superview 是其 owningView
[layoutGuide mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.top.equalToSuperview;
}];
```

### 更新约束
```objc
// 初始约束
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.top.equalToSuperview;
}];

// 后续更新
[childView mas_updateConstraints:^(MASConstraintMaker *make) {
    make.leading.top.equalToSuperview.offset(20);
}];
```

## 与 SnapKit 的对比

### SnapKit 语法
```swift
// SnapKit
view.snp.makeConstraints { make in
    make.leading.top.equalToSuperview()
    make.leading.top.equalToSuperview().inset(10)
}
```

### Masonry 语法（新）
```objc
// Masonry
[view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.top.equalToSuperview;
    make.leading.top.equalToSuperview.inset(10);
}];
```

## 技术实现细节

### 约束链式调用原理
1. 访问 `make.leading` 返回一个新的 MASViewConstraint
2. 访问 `.top` 在上一个约束中调用 `addConstraintWithLayoutAttribute:` 添加新属性，形成 MASCompositeConstraint
3. 访问 `.equalToSuperview/.greaterThanOrEqualToSuperview/.lessThanOrEqualToSuperview` 获取 superview 并为每个子约束调用 `equalToWithRelation:`

### Superview 处理
- 对于 UIView：直接获取 `view.superview`
- 对于 UILayoutGuide：获取 `layoutGuide.owningView`
- 对于 MASCompositeConstraint：逐个子约束独立解析 superview，避免依赖第一个子约束的上下文

### 错误处理
- 如果 superview 为 nil，会立即触发 `NSAssert`
- 建议在设置约束前先将 view/layoutGuide 添加到正确的层级中

## 向后兼容性
- ✅ 完全兼容现有 API
- ✅ 不影响任何现有代码
- ✅ 可以与现有约束方式混合使用

## 性能考虑
- 约束创建过程无性能开销
- superview 的获取在约束设置时进行，不在每次布局更新时重复

## 测试案例
- 示例代码见 `MasonryEqualToSuperviewExample.m`
- 单元测试覆盖了 equal/greater/less 三种 superview 快捷属性，包括普通 view、无 superview 断言，以及 composite constraint 为每个 child 独立解析 superview
