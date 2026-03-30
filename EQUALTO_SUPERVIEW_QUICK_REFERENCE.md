# Masonry equalToSuperview - 快速参考

## 简单用法

```objc
// 单个属性
make.leading.equalToSuperview;
make.top.equalToSuperview;

// 多个属性（链式调用）
make.leading.top.equalToSuperview;
make.trailing.bottom.equalToSuperview;
make.edges.equalToSuperview;
```

## 常见模式

### 1. 全屏填充（无内边距）
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalToSuperview;
}];
```

### 2. 全屏填充（有内边距）
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalToSuperview.insets(UIEdgeInsetsMake(10, 10, 10, 10));
}];
```

### 3. 顶部和两侧对齐
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.top.trailing.equalToSuperview;
    make.height.equalTo(@(60));
}];
```

### 4. 按比例填充
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalToSuperview.multipliedBy(0.9);
}];
```

### 5. 居中对齐
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalToSuperview;
    make.width.height.equalTo(@(200));
}];
```

### 6. 安全区域（旧方法，仍然有效）
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
    make.trailing.equalTo(self.view.mas_safeAreaLayoutGuideRight);
}];
```

## 与旧语法对比

### 旧方法
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.equalTo(childView.superview.mas_leading);
    make.top.equalTo(childView.superview.mas_top);
    make.trailing.equalTo(childView.superview.mas_trailing);
    make.bottom.equalTo(childView.superview.mas_bottom);
}];
```

### 新方法
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalToSuperview;
}];
```

## 修饰符支持

所有标准的 Masonry 修饰符都支持 `equalToSuperview`：

```objc
// offset
make.leading.top.equalToSuperview.offset(10);

// inset
make.edges.equalToSuperview.inset(20);

// multipliedBy
make.width.equalToSuperview.multipliedBy(0.5);

// priority
make.leading.top.equalToSuperview.priorityHigh;

// 组合
make.edges.equalToSuperview.insets(UIEdgeInsetsMake(10, 10, 10, 10)).priorityMedium;
```

## 适用的属性

以下所有属性都支持 `equalToSuperview`：

- `leading`
- `trailing`
- `top`
- `bottom`
- `left`
- `right`
- `centerX`
- `centerY`
- `width`
- `height`
- `edges`
- `size`
- `center`

以及所有边距属性（iOS/tvOS）：
- `leadingMargin`
- `trailingMargin`
- `topMargin`
- `bottomMargin`
- 等等

## 高级用法

### 条件约束
```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    if (isLandscape) {
        make.leading.top.trailing.bottom.equalToSuperview;
    } else {
        make.leading.trailing.bottom.equalToSuperview;
        make.top.equalTo(statusBar.mas_bottom);
    }
}];
```

### 支持 UILayoutGuide
```objc
// iOS 9.0+
UILayoutGuide *guide = [[UILayoutGuide alloc] init];
[view addLayoutGuide:guide];

[guide mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.top.equalToSuperview;
    make.width.height.equalTo(@(100));
}];
```

### 分组更新
```objc
[childView mas_updateConstraints:^(MASConstraintMaker *make) {
    make.edges.equalToSuperview.insets(UIEdgeInsetsMake(15, 15, 15, 15));
}];
```

## Nil 检查

虽然通常不需要显式检查，但如果需要：

```objc
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    if (childView.superview != nil) {
        make.edges.equalToSuperview;
    }
}];
```

## 常见错误

❌ **错误**：在父视图之前设置约束
```objc
UIView *childView = [[UIView alloc] init];
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalToSuperview;  // superview 还是 nil
}];
[parentView addSubview:childView];
```

✅ **正确**：先添加到视图层级
```objc
UIView *childView = [[UIView alloc] init];
[parentView addSubview:childView];
[childView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalToSuperview;
}];
```

## 性能提示

- `equalToSuperview` 是一个属性而不是方法，无需 `()` 调用
- 约束计算只在设置时进行，不影响布局性能
- 链式调用不会增加任何开销

## 完整示例

```objc
- (void)setupUI {
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:containerView];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor redColor];
    [containerView addSubview:contentView];
    
    // containerView 填充父视图
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalToSuperview.insets(UIEdgeInsetsMake(20, 20, 20, 20));
    }];
    
    // contentView 填充 containerView
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalToSuperview.insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
}
```
