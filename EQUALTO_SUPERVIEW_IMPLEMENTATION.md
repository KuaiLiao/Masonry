# Masonry equalToSuperview 功能实现说明

## 概述
为 Masonry 添加了 `equalToSuperview` 方法，参考了 SnapKit 的 API 设计。这允许开发者使用链式调用方式为视图设置与 superview 相等的约束，支持单个或多个属性的组合。

## 主要特性
- ✅ 支持链式调用: `make.leading.top.equalToSuperview`
- ✅ 支持 UIView 和 UILayoutGuide
- ✅ 兼容所有现有的 Masonry 方法（offset、inset、priority 等）
- ✅ 自动获取并处理 superview

## 实现改动

### 1. MASConstraint.h
添加了 `equalToSuperview` 属性：
```objc
/**
 *	Sets the constraint relation to NSLayoutRelationEqual with the superview
 *  This is equivalent to equalTo(self.superview)
 */
@property (nonatomic, copy, readonly) MASConstraint *equalToSuperview;
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
实现了 `equalToSuperview` 属性：
```objc
- (MASConstraint *)equalToSuperview {
    return self.equalToWithRelation([self mas_superview], NSLayoutRelationEqual);
}
```

### 4. MASViewConstraint.m
实现了 `mas_superview` 方法：
```objc
- (id)mas_superview {
    id item = self.firstViewAttribute.item;
    if ([item isKindOfClass:MASLayoutGuide.class]) {
        // For layout guides, return the owning view
        return ((MASLayoutGuide *)item).owningView;
    } else if ([item isKindOfClass:MAS_VIEW.class]) {
        MAS_VIEW *view = (MAS_VIEW *)item;
        return view.superview;
    }
    // Fallback: try to get from firstViewAttribute.view
    return self.firstViewAttribute.view.superview;
}
```

### 5. MASCompositeConstraint.m
为组合约束添加了 `mas_superview` 代理支持：
```objc
- (id)mas_superview {
    // Get superview from the first child constraint
    if (self.childConstraints.count > 0) {
        return [self.childConstraints[0] mas_superview];
    }
    return nil;
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
3. 访问 `.equalToSuperview` 获取 superview 并为每个子约束调用 `equalToWithRelation:` 

### Superview 处理
- 对于 UIView：直接获取 `view.superview`
- 对于 UILayoutGuide：获取 `layoutGuide.owningView`
- MASCompositeConstraint 从第一个子约束获取 superview

### 错误处理
- 如果 superview 为 nil，约束仍会被创建但可能在安装时失败
- 建议在设置约束前确保父视图已正确设置

## 向后兼容性
- ✅ 完全兼容现有 API
- ✅ 不影响任何现有代码
- ✅ 可以与现有约束方式混合使用

## 性能考虑
- 约束创建过程无性能开销
- superview 的获取在约束设置时进行，不在每次布局更新时重复

## 测试案例
详见 `MasonryEqualToSuperviewExample.m` 中的 10 个示例
