# CLAUDE.md — Magic App MVP

## 产品概述

一个 sticker collage 工具。用户从照片中提取主体作为 sticker，在 cutting mat 画布上排版，最终作为 Home Screen Widget 展示。

**产品名 `Magic` 是暂定名，后续会更换。** 所有对产品名的引用通过 `AppConfig.productName` 获取，绝不在 UI 代码中硬编码。

> 工程化说明：项目用 [XcodeGen](https://github.com/yonyz/XcodeGen) 管理。`project.yml` 是工程定义的唯一真相源，`.xcodeproj` 由 `xcodegen generate` 生成。Target membership、App Group、Build Settings 全部在 `project.yml` 中声明——**新增/移动文件后必须重新 `xcodegen generate`**。

---

## MVP 功能范围

| 模块 | 功能 | Phase |
|------|------|-------|
| Onboarding | 3 页滑动引导 | 2 |
| **Home** | **mat 列表 / 缩略图网格 + 新建** | **1 ✅** |
| **Editor** | **单 mat 画布 + 工具栏 + 换色** | **1 ✅** |
| Sticker | 照片选取 + 主体提取 + 拖拽缩放旋转 | 2 |
| Paper Edge | 撕纸边缘效果 | 2 |
| Drawer | Sticker 收藏抽屉 | 2 |
| Wand | AI 自动装饰 | 3 |
| **Save** | **SwiftData 持久化** | **1 ✅** |
| **Widget** | **WidgetKit 桌面组件** | **1 ✅** |
| Collab | CloudKit 协作 | 3 |

**Phase 1 目标：** 首页展示 mat 列表 → 点击/新建进入编辑器 → cutting mat 可换色 → 数据持久化 → Widget 展示选中 mat。

---

## 核心概念模型

- **风格 (MatStyle)**：决定用哪组 Layer + 该风格专属的设计参数 + 画布比例。网格 cutting mat 是一种风格（`GridMatStyle`，`id = "grid"`），未来可新增黑白版、其他视觉体系等完全不同的风格。
- **主题 (MatTheme)** = **风格 ID (`styleID`) + 配色**。同一风格下可以有多套配色（8 套预设）。
- **文档 (MatDocument)** 持有 `styleID` + `themeID`：即"这张 mat 用哪个风格、哪套配色"。

> 渲染链路：`MatDocument(styleID, themeID)` → `MatRenderCache.image(styleID:themeID:size:)` → `MatRenderer.render(size:styleID:colorScheme:)` → `MatStyleRegistry.style(id:)` 取出风格 → 逐层绘制该风格的 `layers`。

---

## 导航结构

```
MagicApp
  └── HomeView (首页 / mat 列表)
        ├── mat 缩略图网格（点击 → 进入编辑器）
        └── "+" 新建 mat（→ 创建后进入编辑器）
              │
              └── EditorView (编辑器 / 单 mat)
                    ├── 全屏 cutting mat 画布
                    ├── 顶部 nav（← 返回首页 / mat 名 / 协作分享占位）
                    └── 底部工具栏（换色 / Aa / + / wand / star）
```

首页和编辑器是两个独立页面，通过 `NavigationStack` 路由。首页持有 mat 列表，编辑器只处理传入的单个 mat。

---

## 项目结构

```
Magic/
├── MagicApp.swift                          // @main 入口 + ModelContainer
│
├── Config/
│   └── AppConfig.swift                     // ★共享 产品名、App Group、Feature Flags
│
├── DesignSystem/
│   └── MatColorScheme.swift                // ★共享 颜色组 + 派生
│
├── Models/
│   ├── MatDocument.swift                   // SwiftData @Model（styleID + themeID，纯数据）
│   ├── MatTheme.swift                      // ★共享 预设主题（styleID + 配色 + UIColor hex 扩展）
│   └── MatStore.swift                      // 列表 CRUD（仅主 App）
│
├── CuttingMat/                             // ★整个目录共享给 Widget（除 MatRenderCache.swift）
│   ├── MatGeometry.swift                   // 画布几何（用 SharedLayoutTokens + GridStyleTokens.Grid）
│   ├── MatLayerProtocol.swift             // MatLayer 协议
│   ├── MatRenderer.swift                   // 纯函数：(size, styleID, colorScheme) → UIImage
│   ├── MatRenderCache.swift               // 渲染缓存（独立于 Model，key 含 styleID）
│   └── Styles/                             // ← 背景风格体系
│       ├── MatStyle.swift                  // 风格协议（id / layers / aspectRatio / clipPath）
│       ├── MatStyleRegistry.swift          // 风格注册表
│       ├── SharedLayoutTokens.swift        // 跨风格共享的画布几何常量
│       └── GridStyle/                      // ← 网格风格（一种 MatStyle 实现）
│           ├── GridMatStyle.swift          // 网格风格定义（layers + clipPath）
│           ├── GridStyleTokens.swift       // 网格风格专属绘制常量
│           └── Layers/
│               ├── BackgroundLayer.swift
│               ├── VignetteLayer.swift
│               ├── GridLayer.swift
│               ├── BorderLayer.swift
│               ├── TickLayer.swift
│               ├── ArcLayer.swift
│               └── NumberLayer.swift
│
├── Features/
│   ├── Onboarding/
│   │   └── OnboardingView.swift            // [Phase 2 stub]
│   ├── Home/
│   │   ├── HomeView.swift                  // mat 列表页
│   │   └── MatThumbnailCard.swift          // 单个 mat 缩略图卡片
│   ├── Editor/
│   │   ├── EditorView.swift
│   │   ├── CuttingMatView.swift
│   │   ├── EditorToolbar.swift
│   │   └── ColorPaletteSheet.swift
│   └── Sticker/                            // [Phase 2 stubs]
│       ├── Sticker.swift
│       ├── StickerCanvasView.swift
│       └── SubjectExtractor.swift
│
├── Services/
│   └── WidgetBridge.swift                  // ★共享 App Group 数据桥接
│
└── Resources/Assets.xcassets/

MagicWidget/                                // ← 独立 Widget Extension Target
├── MagicWidget.swift
├── MagicWidgetBundle.swift
├── MagicWidget.entitlements
└── Info.plist
```

### ★ Widget Target Membership（关键）

以下文件需同时属于 **Magic** 和 **MagicWidget** 两个 target（在 `project.yml` 中 MagicWidget 的 `sources` 显式列出；同一路径被两个 target 引用即为双 membership）：

```
Config/AppConfig.swift
DesignSystem/MatColorScheme.swift
Models/MatTheme.swift                          (含 UIColor hex 扩展)
CuttingMat/ 整个目录（除 MatRenderCache.swift）
  └── 含 Styles/ 全部：MatStyle / MatStyleRegistry / SharedLayoutTokens /
      GridStyle/ 全部（GridMatStyle / GridStyleTokens / Layers/*）
Services/WidgetBridge.swift
```

- `MatDocument.swift`（SwiftData @Model）**不要**给 Widget target——Widget 不直接读数据库，只读 WidgetBridge 写的 PNG。
- `MatRenderCache.swift` 只给主 App（Widget 直接用 `MatRenderer` 渲染兜底图）。
- `WidgetBridge.swift` 是 ★共享，但 `publish(document:)` 依赖 `MatDocument` / `MatRenderCache`（均非 Widget 成员），所以该方法用 `#if !WIDGET` 包裹；MagicWidget target 设置 `SWIFT_ACTIVE_COMPILATION_CONDITIONS = WIDGET`，只编译 `readSnapshot()`。

---

## 构建顺序

```
Step 1  → Xcode 项目初始化（XcodeGen project.yml）
            - App target: Magic (iOS 17+, SwiftUI, SwiftData)
            - App Group: group.com.othric.magic（capability + .entitlements）
            - Widget target 在 Step 12 加入

Step 2  → Config/AppConfig.swift
Step 3  → DesignSystem/MatColorScheme.swift

Step 4  → CuttingMat/Styles/ 基础设施
            - SharedLayoutTokens.swift
            - MatStyle.swift（协议）
            - MatStyleRegistry.swift

Step 5  → CuttingMat/Styles/GridStyle/ （网格风格）
            - GridStyleTokens.swift
            - 7 Layers (Background → Vignette → Grid → Border → Tick → Arc → Number)
            - GridMatStyle.swift
          CuttingMat/ 渲染核心
            - MatGeometry.swift → MatRenderer.swift → MatRenderCache.swift

Step 6  → Models/MatTheme.swift (styleID + 配色预设)
Step 7  → Models/MatDocument.swift (styleID + themeID 纯数据)
Step 8  → Models/MatStore.swift (列表 CRUD)

Step 9  → Features/Editor/ (CuttingMatView → Toolbar → ColorSheet → EditorView)
Step 10 → Features/Home/ (MatThumbnailCard → HomeView)
Step 11 → Services/WidgetBridge.swift
Step 12 → MagicApp.swift (NavigationStack 路由)

Step 13 → MagicWidget/ (配置 target membership + 实现)
Step 14 → Phase 2 stub 文件
```

每步 `xcodegen generate` + `xcodebuild build` 通过后再继续。

---

## 核心文件实现

### AppConfig.swift

```swift
import Foundation

enum AppConfig {
    /// 产品名（暂定，后续会更换。UI 文案全部走这里）
    static let productName = "Magic"
    static let appGroupID = "group.com.othric.magic"

    enum Feature {
        static let onboardingEnabled = false
        static let stickerEnabled = false
        static let collaborationEnabled = false
    }
}
```

### SharedLayoutTokens.swift（跨风格共享的画布几何常量）

```swift
import CoreGraphics

/// 跨风格共享的画布几何常量。被 MatGeometry 使用，与具体风格无关。
/// 各风格可在自己的 MatStyle.aspectRatio 中覆盖默认比例。
enum SharedLayoutTokens {
    static let referenceWidth: CGFloat = 1280
    static let referenceHeight: CGFloat = 590
    static let paddingRatio: CGFloat = 58.0 / 1280.0
    static let cornerRadiusRatio: CGFloat = 44.0 / 1280.0
    static let aspectRatio: CGFloat = 1280.0 / 590.0
}
```

### GridStyleTokens.swift（网格风格专属常量）

> 注意：这是 **网格风格专属** 的 tokens。其它风格各有自己的 tokens 文件。数值与重构前 `MatDesignTokens` 完全一致。

```swift
import CoreGraphics

enum GridStyleTokens {
    enum Grid {
        static let columns = 20
        static let rows = 8
        static let majorColumnInterval = 5
        static let majorRowInterval = 4
        /// 主（亮）竖线相位：位于 col % majorColumnInterval == majorColumnPhase，
        /// 即 col 4/9/14/19——与数字标签列对齐（匹配 Figma 11:872）。
        static let majorColumnPhase = 4
        /// 唯一的主（亮）横线：中线 row 4（顶/底由外框承担）。
        static let majorRowLine = 4
    }
    enum Stroke {
        static let minorGrid: CGFloat = 1.0
        static let majorGrid: CGFloat = 1.4
        static let border: CGFloat = 2.0
        static let arc: CGFloat = 1.5
        static let minorTick: CGFloat = 1.2
        static let majorTick: CGFloat = 1.8
    }
    enum Opacity {
        static let vignette: CGFloat = 0.18
        static let minorGrid: CGFloat = 0.18
        static let majorGrid: CGFloat = 0.80   // 明（主）线，明暗分级（Figma dev 读到 0.5，设计指定 80%）
        static let border: CGFloat = 0.82
        static let tick: CGFloat = 0.72
        static let numberLabel: CGFloat = 0.85
        static let r10Arc: CGFloat = 0.62
        static let r20Arc: CGFloat = 0.56
        static let r10Label: CGFloat = 0.78
    }
    enum Tick {
        static let majorLength: CGFloat = 22
        static let minorLength: CGFloat = 14
    }
    enum Arc {
        static let r10RadiusFactor: CGFloat = 10.05
        static let r20RadiusFactor: CGFloat = 20.15
        static let centerOffsetXFactor: CGFloat = -0.15
        static let centerOffsetYFactor: CGFloat = 0.08
    }
    enum Number {
        static let fontSize: CGFloat = 18
        static let topY: CGFloat = -44
        static let bottomY: CGFloat = 20
        static let leftX: CGFloat = -48
        static let rightX: CGFloat = 24
        static let r10LabelXFactor: CGFloat = 7.23   // Figma: left 479 @ ref → (479-58)/58.2
        static let r10LabelYFactor: CGFloat = 0.62   // Figma: top 95 @ ref → (95-58)/59.25
    }
}
```

### MatColorScheme.swift

```swift
import UIKit

struct MatColorScheme: Equatable {
    let base: UIColor
    let grid: UIColor
    let arc: UIColor
    let vignette: UIColor

    /// Phase 2: 从 base 自动派生
    static func derive(from base: UIColor) -> MatColorScheme {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        base.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let isDark = b < 0.5
        let gridH = fmod(h + 0.28, 1.0)
        let gridS: CGFloat = isDark ? max(s * 0.55, 0.3) : min(s + 0.15, 0.8)
        let gridB: CGFloat = isDark ? min(b + 0.60, 0.85) : max(b - 0.35, 0.35)
        let grid = UIColor(hue: gridH, saturation: gridS, brightness: gridB, alpha: 1)
        let arc = UIColor(hue: fmod(gridH - 0.01, 1.0), saturation: gridS + 0.01,
                          brightness: gridB - 0.02, alpha: 1)
        let vignette = UIColor(hue: h, saturation: min(s + 0.1, 1.0),
                               brightness: max(b - 0.08, 0.0), alpha: 1)
        return MatColorScheme(base: base, grid: grid, arc: arc, vignette: vignette)
    }
}
```

### MatStyle.swift（风格协议）

```swift
import UIKit

/// 一种背景风格：决定用哪组 Layer、专属设计参数与画布比例。
protocol MatStyle {
    var id: String { get }
    var layers: [MatLayer] { get }
    var aspectRatio: CGFloat { get }

    /// 可选：绘制前对整张画布应用的裁剪路径。默认不裁剪。
    /// 网格风格返回圆角矩形，使 R10/R20 完整圆弧被 mat 圆角裁切。
    func clipPath(for geometry: MatGeometry) -> UIBezierPath?
}

extension MatStyle {
    func clipPath(for geometry: MatGeometry) -> UIBezierPath? { nil }
}
```

### MatStyleRegistry.swift（风格注册表）

```swift
/// 背景风格注册表。新增风格时在 `all` 中追加即可。
enum MatStyleRegistry {
    static let all: [MatStyle] = [GridMatStyle()]  // 未来追加新风格

    static func style(id: String) -> MatStyle {
        all.first { $0.id == id } ?? GridMatStyle()
    }
}
```

### GridMatStyle.swift（网格风格）

```swift
import UIKit

struct GridMatStyle: MatStyle {
    let id = "grid"
    var aspectRatio: CGFloat { SharedLayoutTokens.aspectRatio }
    var layers: [MatLayer] {
        [BackgroundLayer(), VignetteLayer(), GridLayer(),
         BorderLayer(), TickLayer(), ArcLayer(), NumberLayer()]
    }

    /// 圆角矩形裁剪，使 R10/R20 完整圆弧被 mat 圆角裁切。
    func clipPath(for g: MatGeometry) -> UIBezierPath? {
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: g.canvasSize),
                     cornerRadius: g.cornerRadius)
    }
}
```

### MatGeometry.swift

> `MatGeometry` 目前同时使用 `SharedLayoutTokens`（画布几何）与 `GridStyleTokens.Grid`（行列数计算 stepX/stepY）。它当前是面向网格的基础设施；将来若出现网格划分不同的风格，可把行列数参数化（见"背景风格扩展"末尾的已知限制）。

```swift
import CoreGraphics

struct MatGeometry {
    let canvasSize: CGSize
    let scale: CGFloat
    let padding, cornerRadius: CGFloat
    let gridOrigin: CGPoint
    let gridSize: CGSize
    let gridEnd: CGPoint
    let stepX, stepY: CGFloat

    init(canvasSize: CGSize) {
        self.canvasSize = canvasSize
        self.scale = canvasSize.width / SharedLayoutTokens.referenceWidth
        self.padding = canvasSize.width * SharedLayoutTokens.paddingRatio
        self.cornerRadius = canvasSize.width * SharedLayoutTokens.cornerRadiusRatio
        let gw = canvasSize.width - padding * 2
        let gh = canvasSize.height - padding * 2
        self.gridOrigin = CGPoint(x: padding, y: padding)
        self.gridSize = CGSize(width: gw, height: gh)
        self.gridEnd = CGPoint(x: padding + gw, y: padding + gh)
        self.stepX = gw / CGFloat(GridStyleTokens.Grid.columns)
        self.stepY = gh / CGFloat(GridStyleTokens.Grid.rows)
    }
    func scaled(_ ref: CGFloat) -> CGFloat { ref * scale }
}
```

### MatLayerProtocol.swift

```swift
import UIKit
protocol MatLayer {
    func draw(in context: CGContext, geometry: MatGeometry, colors: MatColorScheme)
}
```

### Layers — 网格风格 7 个文件（`Styles/GridStyle/Layers/`）

> 逻辑与重构前完全一致，仅 token 引用由 `MatDesignTokens` 改为 `GridStyleTokens`。

**BackgroundLayer.swift**
```swift
import UIKit
struct BackgroundLayer: MatLayer {
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let rect = CGRect(origin: .zero, size: g.canvasSize)
        let clip = UIBezierPath(roundedRect: rect, cornerRadius: g.cornerRadius)
        ctx.addPath(clip.cgPath); ctx.clip()
        ctx.setFillColor(colors.base.cgColor); ctx.fill(rect)
    }
}
```

**VignetteLayer.swift**
```swift
import UIKit
struct VignetteLayer: MatLayer {
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        ctx.setFillColor(colors.vignette.withAlphaComponent(GridStyleTokens.Opacity.vignette).cgColor)
        ctx.fill(CGRect(origin: .zero, size: g.canvasSize))
    }
}
```

**GridLayer.swift**
```swift
import UIKit
struct GridLayer: MatLayer {
    private typealias T = GridStyleTokens
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let G = T.Grid.self

        // ===== 竖线：col 1..19（col0/col20 由外框承担，不在此绘制）=====
        // 次（暗）线
        ctx.setStrokeColor(colors.grid.withAlphaComponent(T.Opacity.minorGrid).cgColor)
        ctx.setLineWidth(g.scaled(T.Stroke.minorGrid))
        for i in 1..<G.columns where i % G.majorColumnInterval != G.majorColumnPhase {
            let x = g.gridOrigin.x + CGFloat(i) * g.stepX
            ctx.move(to: CGPoint(x: x, y: g.gridOrigin.y)); ctx.addLine(to: CGPoint(x: x, y: g.gridEnd.y))
        }
        ctx.strokePath()
        // 主（亮）线：col 4,9,14,19（与数字标签列对齐）
        ctx.setStrokeColor(colors.grid.withAlphaComponent(T.Opacity.majorGrid).cgColor)
        ctx.setLineWidth(g.scaled(T.Stroke.majorGrid))
        for i in stride(from: G.majorColumnPhase, to: G.columns, by: G.majorColumnInterval) {
            let x = g.gridOrigin.x + CGFloat(i) * g.stepX
            ctx.move(to: CGPoint(x: x, y: g.gridOrigin.y)); ctx.addLine(to: CGPoint(x: x, y: g.gridEnd.y))
        }
        ctx.strokePath()

        // ===== 横线：row 1..7（row0/row8 由外框承担，不在此绘制）=====
        // 次（暗）线
        ctx.setStrokeColor(colors.grid.withAlphaComponent(T.Opacity.minorGrid).cgColor)
        ctx.setLineWidth(g.scaled(T.Stroke.minorGrid))
        for j in 1..<G.rows where j != G.majorRowLine {
            let y = g.gridOrigin.y + CGFloat(j) * g.stepY
            ctx.move(to: CGPoint(x: g.gridOrigin.x, y: y)); ctx.addLine(to: CGPoint(x: g.gridEnd.x, y: y))
        }
        ctx.strokePath()
        // 主（亮）线：仅中线 row 4
        ctx.setStrokeColor(colors.grid.withAlphaComponent(T.Opacity.majorGrid).cgColor)
        ctx.setLineWidth(g.scaled(T.Stroke.majorGrid))
        let yMid = g.gridOrigin.y + CGFloat(G.majorRowLine) * g.stepY
        ctx.move(to: CGPoint(x: g.gridOrigin.x, y: yMid)); ctx.addLine(to: CGPoint(x: g.gridEnd.x, y: yMid))
        ctx.strokePath()
    }
}
```

**BorderLayer.swift**
```swift
import UIKit
struct BorderLayer: MatLayer {
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let rect = CGRect(origin: g.gridOrigin, size: g.gridSize)
        colors.grid.withAlphaComponent(GridStyleTokens.Opacity.border).setStroke()
        let p = UIBezierPath(rect: rect)
        p.lineWidth = g.scaled(GridStyleTokens.Stroke.border)
        p.stroke()
    }
}
```

**TickLayer.swift**（刻度在边框外侧，用 fill rect）
```swift
import UIKit
struct TickLayer: MatLayer {
    private typealias T = GridStyleTokens
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let G = T.Grid.self
        let c = colors.grid.withAlphaComponent(T.Opacity.tick); c.setFill()
        for i in 0...G.columns {
            let x = g.gridOrigin.x + CGFloat(i) * g.stepX
            let major = i % G.majorColumnInterval == 0
            let len = g.scaled(major ? T.Tick.majorLength : T.Tick.minorLength)
            let th = g.scaled(major ? T.Stroke.majorTick : T.Stroke.minorTick)
            ctx.fill(CGRect(x: x - th/2, y: g.gridOrigin.y - len, width: th, height: len))
            ctx.fill(CGRect(x: x - th/2, y: g.gridEnd.y, width: th, height: len))
        }
        for j in 0...G.rows {
            let y = g.gridOrigin.y + CGFloat(j) * g.stepY
            let major = j % G.majorRowInterval == 0
            let len = g.scaled(major ? T.Tick.majorLength : T.Tick.minorLength)
            let th = g.scaled(major ? T.Stroke.majorTick : T.Stroke.minorTick)
            ctx.fill(CGRect(x: g.gridOrigin.x - len, y: y - th/2, width: len, height: th))
            ctx.fill(CGRect(x: g.gridEnd.x, y: y - th/2, width: len, height: th))
        }
    }
}
```

**ArcLayer.swift**（完整圆；先裁到网格矩形使弧线下方不溢出最底部水平线，再由 `GridMatStyle.clipPath` 圆角裁切）
```swift
import UIKit
struct ArcLayer: MatLayer {
    private typealias T = GridStyleTokens
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        // 弧线限制在网格矩形内：下方不超过最底部水平线（gridEnd.y），四边不溢出刻度/数字区。
        ctx.clip(to: CGRect(origin: g.gridOrigin, size: g.gridSize))
        let cx = g.gridOrigin.x + g.stepX * T.Arc.centerOffsetXFactor
        let cy = g.gridEnd.y + g.stepY * T.Arc.centerOffsetYFactor
        let r10 = g.stepX * T.Arc.r10RadiusFactor
        let r20 = g.stepX * T.Arc.r20RadiusFactor
        let lw = g.scaled(T.Stroke.arc)
        func ring(_ r: CGFloat, _ op: CGFloat) {
            let p = UIBezierPath(arcCenter: CGPoint(x: cx, y: cy), radius: r,
                                 startAngle: 0, endAngle: .pi*2, clockwise: true)
            colors.arc.withAlphaComponent(op).setStroke(); p.lineWidth = lw; p.stroke()
        }
        ring(r10, T.Opacity.r10Arc)
        ring(r20, T.Opacity.r20Arc)
    }
}
```

**NumberLayer.swift**
```swift
import UIKit
struct NumberLayer: MatLayer {
    private typealias T = GridStyleTokens
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let G = T.Grid.self, N = T.Number.self
        let fs = g.scaled(N.fontSize)
        // Figma 设计字体为 Roboto Mono Regular；未打包字体时用系统等宽字体兜底（SF Mono）。
        let font = UIFont(name: "RobotoMono-Regular", size: fs)
            ?? .monospacedSystemFont(ofSize: fs, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: colors.grid.withAlphaComponent(T.Opacity.numberLabel)
        ]
        let topY = g.gridOrigin.y + g.scaled(N.topY)
        let botY = g.gridEnd.y + g.scaled(N.bottomY)
        // 数字 5/10/15/20 居中在主亮线列 col 4,9,14,19（与 GridLayer 主竖线对齐）
        for col in stride(from: G.majorColumnPhase, to: G.columns, by: G.majorColumnInterval) {
            let n = col + 1   // 4→5, 9→10, 14→15, 19→20
            let x = g.gridOrigin.x + CGFloat(col) * g.stepX
            let t = "\(n)" as NSString
            let sz = t.size(withAttributes: attrs)
            t.draw(at: CGPoint(x: x - sz.width/2, y: topY), withAttributes: attrs)
            t.draw(at: CGPoint(x: x - sz.width/2, y: botY), withAttributes: attrs)
        }
        let leftX = g.gridOrigin.x + g.scaled(N.leftX)
        let rightX = g.gridEnd.x + g.scaled(N.rightX)
        for row in stride(from: G.majorRowInterval, to: G.rows, by: G.majorRowInterval) {
            let y = g.gridOrigin.y + CGFloat(row) * g.stepY
            let t = (row == 4 ? "5" : "\(row)") as NSString
            let sz = t.size(withAttributes: attrs)
            t.draw(at: CGPoint(x: leftX, y: y - sz.height/2), withAttributes: attrs)
            t.draw(at: CGPoint(x: rightX, y: y - sz.height/2), withAttributes: attrs)
        }
        let r10Attrs: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: colors.grid.withAlphaComponent(T.Opacity.r10Label)
        ]
        ("R10" as NSString).draw(
            at: CGPoint(x: g.gridOrigin.x + g.stepX * N.r10LabelXFactor,
                        y: g.gridOrigin.y + g.stepY * N.r10LabelYFactor),
            withAttributes: r10Attrs)
    }
}
```

### MatRenderer.swift（纯函数，按 styleID 取风格）

```swift
import UIKit

enum MatRenderer {
    static func render(size: CGSize, styleID: String, colorScheme: MatColorScheme) -> UIImage {
        let style = MatStyleRegistry.style(id: styleID)
        let geo = MatGeometry(canvasSize: size)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext
            // 风格可选的整画布裁剪（网格风格返回圆角矩形）。在层循环外设置，
            // 因而能跨每层的 save/restore 持续生效。
            if let clip = style.clipPath(for: geo) {
                c.addPath(clip.cgPath); c.clip()
            }
            for layer in style.layers {
                c.saveGState()
                layer.draw(in: c, geometry: geo, colors: colorScheme)
                c.restoreGState()
            }
        }
    }
}
```

### MatRenderCache.swift（缓存独立于 Model，key 含 styleID）

```swift
import UIKit

/// 渲染缓存。key = styleID + themeID + size，避免重复渲染同一配置。
/// 与 SwiftData Model 解耦，不依赖 @Transient。
final class MatRenderCache {
    static let shared = MatRenderCache()
    private var cache: [String: UIImage] = [:]
    private let queue = DispatchQueue(label: "mat.render.cache")

    private func key(styleID: String, themeID: String, size: CGSize) -> String {
        "\(styleID)_\(themeID)_\(Int(size.width))x\(Int(size.height))"
    }

    func image(styleID: String, themeID: String, size: CGSize) -> UIImage {
        let k = key(styleID: styleID, themeID: themeID, size: size)
        if let hit = queue.sync(execute: { cache[k] }) { return hit }
        let theme = MatTheme.preset(id: themeID)
        let img = MatRenderer.render(size: size, styleID: styleID, colorScheme: theme.colorScheme)
        queue.sync { cache[k] = img }
        return img
    }

    func invalidate(themeID: String) {
        queue.sync { cache = cache.filter { !$0.key.contains("_\(themeID)_") } }
    }
}
```

### MatTheme.swift

```swift
import SwiftUI

struct MatTheme: Identifiable, Equatable {
    let id: String
    let styleID: String   // 该主题所属的风格（现有预设均为 "grid"）
    let baseHex, gridHex, arcHex, vignetteHex: String

    var colorScheme: MatColorScheme {
        MatColorScheme(
            base: UIColor(hex: baseHex), grid: UIColor(hex: gridHex),
            arc: UIColor(hex: arcHex), vignette: UIColor(hex: vignetteHex)
        )
    }
    var baseColor: Color { Color(uiColor: colorScheme.base) }
    var gridColor: Color { Color(uiColor: colorScheme.grid) }

    static func preset(id: String) -> MatTheme {
        allPresets.first { $0.id == id } ?? .defaultGreen
    }
}

extension MatTheme {
    static let defaultGreen = MatTheme(id: "green", styleID: "grid", baseHex: "#063B31", gridHex: "#C4CF5D", arcHex: "#B8C95A", vignetteHex: "#052820")
    static let pink = MatTheme(id: "pink", styleID: "grid", baseHex: "#F2C7D1", gridHex: "#8C4D5A", arcHex: "#854759", vignetteHex: "#D9AEBB")
    static let navy = MatTheme(id: "navy", styleID: "grid", baseHex: "#0F193D", gridHex: "#99B3D9", arcHex: "#8CA6CC", vignetteHex: "#0A1230")
    static let charcoal = MatTheme(id: "charcoal", styleID: "grid", baseHex: "#242426", gridHex: "#8C8C80", arcHex: "#808076", vignetteHex: "#1A1A1A")
    static let brown = MatTheme(id: "brown", styleID: "grid", baseHex: "#332114", gridHex: "#B89E66", arcHex: "#AD9461", vignetteHex: "#24170D")
    static let wine = MatTheme(id: "wine", styleID: "grid", baseHex: "#40141F", gridHex: "#C78073", arcHex: "#BA766B", vignetteHex: "#2E0A14")
    static let teal = MatTheme(id: "teal", styleID: "grid", baseHex: "#0D3338", gridHex: "#73BFAD", arcHex: "#6BB3A3", vignetteHex: "#082429")
    static let slate = MatTheme(id: "slate", styleID: "grid", baseHex: "#292E38", gridHex: "#9EADBF", arcHex: "#94A1B3", vignetteHex: "#1C2129")

    static let allPresets: [MatTheme] = [.defaultGreen, .pink, .navy, .charcoal, .brown, .wine, .teal, .slate]
}

extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
```

### MatDocument.swift（纯数据 SwiftData Model）

```swift
import SwiftData
import Foundation

@Model
final class MatDocument {
    @Attribute(.unique) var id: UUID
    var name: String
    /// 背景风格 ID（默认 "grid"，default 值供 SwiftData 轻量迁移使用）
    var styleID: String = "grid"
    var themeID: String
    var createdAt: Date
    var updatedAt: Date

    var theme: MatTheme { MatTheme.preset(id: themeID) }

    init(name: String = "my mat",
         styleID: String = "grid",
         themeID: String = MatTheme.defaultGreen.id) {
        self.id = UUID()
        self.name = name
        self.styleID = styleID
        self.themeID = themeID
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func setTheme(_ theme: MatTheme) {
        styleID = theme.styleID
        themeID = theme.id
        updatedAt = Date()
        MatRenderCache.shared.invalidate(themeID: theme.id)
    }
}
```

### MatStore.swift

```swift
import SwiftData
import Foundation

/// mat 列表 CRUD
enum MatStore {
    static func createMat(context: ModelContext) -> MatDocument {
        let mat = MatDocument()
        context.insert(mat)
        try? context.save()
        return mat
    }

    static func delete(_ mat: MatDocument, context: ModelContext) {
        context.delete(mat)
        try? context.save()
    }
}
```

### HomeView.swift（首页 / mat 列表）

```swift
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \MatDocument.updatedAt, order: .reverse) private var mats: [MatDocument]
    @State private var path: [MatDocument] = []

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.white.ignoresSafeArea()

                if mats.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(mats) { mat in
                                MatThumbnailCard(mat: mat)
                                    .onTapGesture { path.append(mat) }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(AppConfig.productName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { createAndOpen() } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: MatDocument.self) { mat in
                EditorView(document: mat)
            }
        }
        .preferredColorScheme(.light)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48)).foregroundStyle(.secondary.opacity(0.6))
            Text("No mats yet").foregroundStyle(.secondary)
            Button { createAndOpen() } label: {
                Text("Create your first mat")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(MatTheme.defaultGreen.baseColor)
                    .clipShape(Capsule())
            }
        }
    }

    private func createAndOpen() {
        let mat = MatStore.createMat(context: context)
        path.append(mat)
    }
}
```

### MatThumbnailCard.swift

```swift
import SwiftUI

struct MatThumbnailCard: View {
    let mat: MatDocument

    private var aspectRatio: CGFloat {
        MatStyleRegistry.style(id: mat.styleID).aspectRatio
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = w / aspectRatio
                Image(uiImage: MatRenderCache.shared.image(
                    styleID: mat.styleID,
                    themeID: mat.themeID,
                    size: CGSize(width: w * 2, height: h * 2)  // @2x 清晰度
                ))
                .resizable()
                .frame(width: w, height: h)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .aspectRatio(aspectRatio, contentMode: .fit)

            Text(mat.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }
}
```

### EditorView.swift

```swift
import SwiftUI
import PhotosUI

struct EditorView: View {
    @Bindable var document: MatDocument
    @Environment(\.dismiss) private var dismiss
    @State private var showColorPicker = false
    @State private var showPhotoPicker = false
    @State private var pickedPhoto: PhotosPickerItem?   // Phase 2 处理为 sticker

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                CuttingMatView(styleID: document.styleID, themeID: document.themeID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                EditorToolbar(
                    baseColor: document.theme.baseColor,
                    gridColor: document.theme.gridColor,
                    onColorTap: { showColorPicker = true },
                    onAddTap: { showPhotoPicker = true }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showColorPicker) {
            ColorPaletteSheet(currentThemeID: document.themeID) { theme in
                document.setTheme(theme)
                WidgetBridge.publish(document: document)
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $pickedPhoto, matching: .images)
        .onDisappear {
            WidgetBridge.publish(document: document)
        }
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3).foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(.black.opacity(0.06)).clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 4) {
                Text(document.name).font(.body.weight(.medium)).foregroundStyle(.primary)
                Image(systemName: "chevron.down").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "person.2.badge.plus").font(.body).foregroundStyle(.primary)
                Image(systemName: "square.and.arrow.up").font(.body).foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
    }
}
```

### CuttingMatView.swift（接收 styleID + themeID，走缓存）

```swift
import SwiftUI

struct CuttingMatView: View {
    let styleID: String
    let themeID: String

    var body: some View {
        GeometryReader { geo in
            let size = matSize(in: geo.size)
            Image(uiImage: MatRenderCache.shared.image(
                styleID: styleID,
                themeID: themeID,
                size: CGSize(width: size.width * 2, height: size.height * 2)
            ))
            .resizable()
            .frame(width: size.width, height: size.height)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }

    private func matSize(in available: CGSize) -> CGSize {
        let ratio = MatStyleRegistry.style(id: styleID).aspectRatio
        let maxW = available.width - 32
        let maxH = available.height
        var w = maxW; var h = w / ratio
        if h > maxH { h = maxH; w = h * ratio }
        return CGSize(width: w, height: h)
    }
}
```

### EditorToolbar.swift

```swift
import SwiftUI

struct EditorToolbar: View {
    let baseColor: Color
    let gridColor: Color
    var onColorTap: () -> Void
    var onAddTap: () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            item {
                Circle().fill(baseColor).frame(width: 26, height: 26)
                    .overlay(Circle().strokeBorder(gridColor.opacity(0.6), lineWidth: 1.5))
            } action: { onColorTap() }

            item { Text("Aa").font(.system(size: 18, weight: .medium)).foregroundStyle(.primary) } action: {}

            Button { onAddTap() } label: {
                Image(systemName: "plus").font(.title2.weight(.medium)).foregroundStyle(.white)
                    .frame(width: 52, height: 52).background(baseColor).clipShape(Circle())
            }.padding(.horizontal, 12)

            item { Image(systemName: "wand.and.stars").font(.system(size: 18)).foregroundStyle(.primary) } action: {}
            item { Image(systemName: "star").font(.system(size: 18)).foregroundStyle(.primary) } action: {}
        }
        .padding(.vertical, 12).padding(.bottom, 8)
    }

    @ViewBuilder
    private func item<C: View>(@ViewBuilder content: () -> C, action: @escaping () -> Void) -> some View {
        Button(action: action) { content().frame(width: 44, height: 44) }
            .frame(maxWidth: .infinity)
    }
}
```

### ColorPaletteSheet.swift（只用回调，无错误 Binding）

```swift
import SwiftUI

struct ColorPaletteSheet: View {
    let currentThemeID: String
    var onSelect: (MatTheme) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: String

    init(currentThemeID: String, onSelect: @escaping (MatTheme) -> Void) {
        self.currentThemeID = currentThemeID
        self.onSelect = onSelect
        _selectedID = State(initialValue: currentThemeID)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(MatTheme.allPresets) { theme in
                        let isSel = selectedID == theme.id
                        Circle()
                            .fill(theme.baseColor)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().strokeBorder(.white, lineWidth: isSel ? 2.5 : 0))
                            .scaleEffect(isSel ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: isSel)
                            .onTapGesture {
                                selectedID = theme.id
                                onSelect(theme)
                            }
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16)
                Spacer()
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Mat Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }
}
```

### WidgetBridge.swift（含更新触发）

```swift
import UIKit
import WidgetKit

enum WidgetBridge {
    private static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConfig.appGroupID)
    }
    private static var imageURL: URL? { containerURL?.appendingPathComponent("widget_mat.png") }

    /// Widget 默认渲染尺寸（systemMedium 近似像素，@2x）
    private static let widgetRenderSize = CGSize(width: 676, height: 312)

    #if !WIDGET
    /// App 侧：发布当前 mat 到 Widget 并触发刷新
    static func publish(document: MatDocument) {
        let image = MatRenderCache.shared.image(
            styleID: document.styleID, themeID: document.themeID, size: widgetRenderSize
        )
        guard let data = image.pngData(), let url = imageURL else { return }
        try? data.write(to: url)
        WidgetCenter.shared.reloadAllTimelines()
    }
    #endif

    /// Widget 侧：读取
    static func readSnapshot() -> UIImage? {
        guard let url = imageURL, let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
```

### MagicApp.swift

```swift
import SwiftUI
import SwiftData

@main
struct MagicApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: MatDocument.self)
    }
}
```

### MagicWidget/MagicWidget.swift

> Widget 兜底渲染直接走 `MatRenderer.render(size:styleID:colorScheme:)`（不经 `MatRenderCache`，因为缓存只属于主 App）。

```swift
import WidgetKit
import SwiftUI

struct MagicEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
}

struct MagicProvider: TimelineProvider {
    func placeholder(in c: Context) -> MagicEntry { MagicEntry(date: .now, image: nil) }
    func getSnapshot(in c: Context, completion: @escaping (MagicEntry) -> Void) {
        completion(MagicEntry(date: .now, image: WidgetBridge.readSnapshot()))
    }
    func getTimeline(in c: Context, completion: @escaping (Timeline<MagicEntry>) -> Void) {
        let entry = MagicEntry(date: .now, image: WidgetBridge.readSnapshot())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct MagicWidgetView: View {
    let entry: MagicEntry

    private var uiImage: UIImage {
        entry.image ?? MatRenderer.render(
            size: CGSize(width: 676, height: 312),
            styleID: "grid",
            colorScheme: MatTheme.defaultGreen.colorScheme)
    }

    var body: some View {
        // mat 图作为 widget 背景铺满整个 widget（含系统默认 content margin 区域），
        // 由 widget 系统圆角裁切，避免 margin 处露出黑边。
        Color.clear
            .containerBackground(for: .widget) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
    }
}

struct MagicWidget: Widget {
    let kind = "MagicWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MagicProvider()) { entry in
            MagicWidgetView(entry: entry)
        }
        .configurationDisplayName(AppConfig.productName)
        .description("Your mat on your home screen")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
```

### MagicWidget/MagicWidgetBundle.swift

```swift
import WidgetKit
import SwiftUI

@main
struct MagicWidgetBundle: WidgetBundle {
    var body: some Widget { MagicWidget() }
}
```

---

## 背景风格扩展

背景风格是一等概念。**风格 (Style) 决定视觉体系（用哪组 Layer + 专属参数 + 画布比例），主题 (Theme) = 风格 + 配色。** 换色只改 Theme（同一风格内换配色）；换风格则切换整套 Layer 组。

### `MatStyle` 协议的作用

`MatStyle` 把"一种背景长什么样"抽象出来：

- `id`：风格唯一标识（写进 `MatTheme.styleID` / `MatDocument.styleID`）。
- `layers`：该风格的绘制层数组，按顺序绘制。
- `aspectRatio`：该风格的画布宽高比（不同风格可不同）。
- `clipPath(for:)`：可选的整画布裁剪路径，默认 `nil`（不裁剪）。网格风格返回圆角矩形，使完整圆弧被圆角裁切。

`MatRenderer` 不再写死任何风格——它根据 `styleID` 从 `MatStyleRegistry` 取出风格，应用其 `clipPath`，再逐层绘制其 `layers`。

### 如何新增一个风格（以"黑白版"为例）

1. **建目录**：`CuttingMat/Styles/MonoStyle/`。
2. **写专属 tokens**：`MonoStyleTokens.swift`（该风格自己的线宽、透明度、几何参数等）。绝不复用 `GridStyleTokens`——每个风格的 tokens 独立。
3. **写该风格的 Layer**：`MonoStyle/Layers/*.swift`，每个实现 `MatLayer` 协议，数值全部从 `MonoStyleTokens` 引用，不出现裸数字。
4. **实现 `MatStyle`**：`MonoMatStyle.swift`：
   ```swift
   struct MonoMatStyle: MatStyle {
       let id = "mono"
       var aspectRatio: CGFloat { /* 该风格比例 */ }
       var layers: [MatLayer] { [ /* 该风格的 Layer 们 */ ] }
       // 需要圆角裁剪才覆盖 clipPath，否则用默认（不裁剪）
   }
   ```
5. **注册**：在 `MatStyleRegistry.all` 追加 `MonoMatStyle()`。
6. **在 `MatTheme` 引用**：新增该风格的预设，`styleID: "mono"` + 对应配色。
7. **Widget target membership**：新增的所有文件都在 `CuttingMat/` 下，已被 MagicWidget 的 `CuttingMat` 目录引用自动覆盖——重新 `xcodegen generate` 即可。

完成后，任何 `MatDocument.styleID == "mono"` 的 mat 会自动用新风格渲染，换色、缓存、Widget 全链路无需改动（它们都按 `styleID` 透传）。

### 已知限制（未来工作）

`MatGeometry` 目前用 `GridStyleTokens.Grid.columns/rows` 计算 `stepX/stepY`，即默认按 20×8 网格切分。若某个新风格需要不同的网格划分（或根本没有网格概念），应把行列数提升为 `MatGeometry` 的初始化参数、或由风格提供几何，避免共享几何依赖某个具体风格的 tokens。

---

## Figma 设计同步工作流

从 Figma Scripter（或设计稿）同步 mat 视觉参数到代码时：

1. **先确认是哪个风格 (styleID)**。不同风格对应不同的 tokens 文件与 Layer 目录：
   - 网格版 → `styleID = "grid"` → `Styles/GridStyle/GridStyleTokens.swift` + `Styles/GridStyle/Layers/`
   - 黑白版 → `styleID = "mono"` → `Styles/MonoStyle/MonoStyleTokens.swift` + `Styles/MonoStyle/Layers/`
2. **只改对应风格的 tokens 文件**：颜色 hex、opacity、线宽、网格几何等参数全部落在该风格自己的 `*StyleTokens` 里，不要改到 `SharedLayoutTokens`（除非确实是跨风格的画布级几何）。
3. **跨风格共享的画布几何**（参考尺寸、padding 比例、圆角比例）才放 `SharedLayoutTokens`。
4. 同步后用一张参考尺寸（如 1280×590）渲染对比 Figma 输出，确认像素一致再提交。

---

## Phase 2 Stub 文件

```swift
// OnboardingView.swift
import SwiftUI
struct OnboardingView: View {
    var onComplete: () -> Void
    var body: some View { Text("Onboarding — Phase 2").onAppear { onComplete() } }
}

// Sticker.swift
import Foundation
struct Sticker: Identifiable, Codable {
    let id: UUID
    var imageData: Data
    var position: CGPoint
    var scale: CGFloat
    var rotation: CGFloat
    var zIndex: Int
    var hasPaperEdge: Bool
}

// StickerCanvasView.swift
import SwiftUI
struct StickerCanvasView: View { var body: some View { EmptyView() } }

// SubjectExtractor.swift
import UIKit
enum SubjectExtractor {
    static func extract(from image: UIImage) async throws -> UIImage {
        fatalError("Phase 2")
    }
}
```

---

## 验收标准

### 首页
- [ ] 启动显示 mat 列表（空态有引导按钮）
- [ ] mat 以缩略图卡片网格展示，显示渲染好的 mat 预览图
- [ ] "+" 新建 mat 后直接进入编辑器
- [ ] 导航标题用 `AppConfig.productName`

### 编辑器
- [ ] 从首页点击 mat 进入，全屏画布
- [ ] ← 返回首页
- [ ] mat 视觉与 Figma Scripter 深绿输出一致
- [ ] 网格 20×8，竖向粗线每 5 列，横向每 4 行
- [ ] 刻度在边框外侧，长短区分
- [ ] R10 + R20 双弧线被圆角裁切
- [ ] 数字 "5" "10" "15" "20" 位置正确
- [ ] 工具栏色盘弹出 8 套主题，选色实时换色

### 持久化 + Widget
- [ ] 换色后退出重进，主题保持
- [ ] Home Screen 添加 Widget 显示选中 mat
- [ ] 编辑器内换色 / 退出后 Widget 同步更新

### 架构
- [ ] 风格 (MatStyle) 与主题 (MatTheme) 解耦：渲染按 styleID 取风格
- [ ] 新增风格只需实现 MatStyle + 写 Layer + 注册 + 在 MatTheme 引用，不改 Renderer/Cache/View
- [ ] 网格风格 tokens 在 GridStyleTokens，跨风格几何在 SharedLayoutTokens

### 工程
- [ ] 两个 target，App Group 共享配置正确
- [ ] Widget target membership 包含所有 ★共享 文件（含 Styles/ 全部）
- [ ] 产品名仅在 AppConfig 出现
- [ ] 所有绘制数值来自对应风格的 *StyleTokens / SharedLayoutTokens，无裸数字
```
