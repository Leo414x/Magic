# Changelog

本项目从零搭建到现在的逐轮进展记录（倒序，最新在上）。完整技术规格见 [TECH_MVP.md](TECH_MVP.md)，项目说明见 [CLAUDE.md](CLAUDE.md)。

## 杂志海报（独立功能）
- 新增独立「海报」功能：MAGAZINE SKATEBOARD 模板(Figma 27:242)，Bowlby One SC 字体经 WKWebView 渲染海报背景
- `PosterDocument` + `PosterEditorView`；Home 加海报入口(doc.richtext)，fullScreenCover 呈现
- 人像：上传照片 → Vision 抠主体 → 右下椭圆槽填充(彩色, scaledToFill + Ellipse 裁剪)，支持**缩放(pinch) + 椭圆内拖动(drag)** 调整，持久化
- 占位提示(虚线椭圆 + 文案)由 app 在**无人像时**显示，背景图本身不含(填入人像后自动消失)

## Phase 2 — Sticker（进行中）

### 装饰贴纸(WOW/手/墨镜) + 贴纸库 + 阴影
- 新增装饰贴纸：WOW 3D(Figma 28:587, 9 层矢量+Bungee 字体经 WKWebView 渲染) + 摇滚手 + 像素墨镜(Vision 抠掉背景只留透明主体)
- 新建「贴纸库」面板 `StickerLibrarySheet`：装饰预设(WOW) + 文字模板(good vibes) + 我的收藏，统一入口(工具栏 star)；`DecorSticker` 预设枚举(加装饰只需加 case + Asset)
- 贴纸 drop shadow(沿轮廓投影, 不透明度 0.18)：画布 + Widget/缩略图合成一致
- 签名:`DEVELOPMENT_TEAM` 固定进 project.yml(三 target 自动签名)

### sticker 选中 / 图层顺序 / 二次编辑
- 点选 sticker（虚线框高亮，点画布空白取消选中）
- 选中后底部浮 Liquid Glass 操作条：前移 / 后移图层（zIndex 交换）、删除
- 文字 sticker 二次编辑：选中 → 改字 → 重渲染并更新（复用文字编辑面板）

### good vibes 文字 sticker
- Figma 5 层透明 SVG → WKWebView 渲染透明背景，打包 Oleo Script 字体
- `TextStickerRenderer` 合成「背景 + 可编辑文字」；工具栏 Aa → Liquid Glass 文字面板（实时预览）→ 落地
- `StickerItem` 加 `kind/text/templateId`；文字 sticker 走 imageData，与照片纸边 sticker 区分

### 修复
- 首页缩略图合成 sticker 且随编辑刷新
- Sticker 编辑中间态点击闪屏（预览改 @State，避免每帧跑滤镜）

### 轮 4b · Sticker 编辑中间态（Liquid Glass）
- `StickerEditorSheet`：选图抠图后从下方升起的中间态面板——实时预览 + 切 `none/clean/torn/ripped` + 选边缘颜色 + 调厚度，确认后才落地（取消则丢弃）
- `liquidGlass` 适配：iOS 26 用 `.glassEffect(.regular,…)`，旧系统降级 `.regularMaterial`
- 预览用缩小图（最长边 420）跑实时滤镜避免卡顿，落地用全分辨率
- 选图流程改为「选图 → 抠图 → 中间态面板 → 确认贴到 mat」

### 轮 4a · 撕纸边缘引擎
- 新增 `PaperEdge` 渲染引擎，3 种纸边风格：`clean`（均匀白边 / die-cut）、`torn`（细颗粒磨砂毛边）、`ripped`（碎纸张：低频起伏 + 高频毛刺两层位移）
- 纸边**颜色**与**厚度**可调
- `StickerItem` 增加 `edgeStyle / edgeColor / edgeWidth` 字段（默认无边，兼容旧数据）
- `StickerRendering`（带缓存）统一供画布显示与 Widget 合成，两处效果一致
- render 测试验证三种风格

### 轮 3 · 贴纸收藏抽屉（Drawer）
- 新增 `SavedSticker`（全局 @Model，跨 mat 复用），注册进 ModelContainer
- 抠出的 sticker 自动收藏进抽屉
- `StickerDrawerSheet`：网格展示收藏、点选复用到当前 mat、长按删除；空态引导
- 工具栏 star 作为抽屉入口

### 轮 2 · Widget 合成 sticker
- 新增 `StickerCompositor`：按归一化位置 / 缩放 / 旋转把 sticker 合成进 Widget 的 mat 图，坐标规则与画布一致
- `WidgetBridge.publish` 改用合成图——换色 / 加 sticker / 退出编辑器都会推送带贴纸的 mat

### 轮 1 · 核心 sticker 闭环
- `SubjectExtractor`：iOS 17 Vision 自动抠主体（后台队列，失败回退整张图）
- `StickerItem`（SwiftData @Model）：图片 + 归一化位置 / 缩放 / 旋转 / zIndex；`MatDocument` cascade 关系持有
- `StickerCanvasView`：mat 上叠加 sticker，支持拖拽 / 双指缩放 / 旋转，结束即持久化
- `EditorView`：点 `+` → 选照片 → 抠图 → 贴到 mat → 存库 → 刷新 Widget 全流程（PhotosPicker）

## 文档 & 多设备协同
- `CLAUDE.md` 拆分：原规格更名 `TECH_MVP.md`（规格快照，不再逐行同步代码）；新建 `CLAUDE.md` 作为项目入口（背景 / 当前状态 / 多设备协同 / 跨会话约定）
- `git init` + `.gitignore`（忽略 `Magic.xcodeproj`/`build`/`_verify`/DerivedData），首版推送到 https://github.com/Leo414x/Magic
- 多设备用 git 同步（不用 iCloud）：换机 `git pull` → `xcodegen generate` → build

## 视觉对齐 Figma & 微调
- 对齐 Figma 节点 11:765（初版 cutting mat）：字体改 Roboto Mono / SF Mono 兜底、R10 标签位置、数字定位
- app 外围背景改白色 + 浅色 UI（mat 本身仍为主题色）
- 对齐 Figma 节点 11:872（新版网格分割）：主亮线移到 col 4/9/14/19 + 中线 row 4、明线透明度 0.8、最外圈内部线交给外框、数字居中到亮线列
- 微调：外框 2.5 / 100% 不透明、R10 标签贴弧线 2px（几何定位）、弧线仅下方截断（不溢出最底部水平线）、数字 100% 不透明
- 修复：Widget 左右黑边（图铺满 containerBackground）、编辑器 `+` 调起系统相册、弧线溢出底部

## 架构重构 — 风格一等公民
- 抽象 `MatStyle` 协议（`id / layers / aspectRatio / clipPath`）→ `MatStyleRegistry` → `GridMatStyle`
- `CuttingMatRenderer` → `MatRenderer`（按 styleID 取风格驱动渲染）
- 设计 token 拆分：`SharedLayoutTokens`（画布几何）+ 各风格私有 `GridStyleTokens`
- `styleID` 贯穿 `MatTheme` / `MatDocument` / `MatRenderCache` / 视图层；主题 = 风格 + 配色

## Phase 1 — MVP 核心（完成）
- XcodeGen 工程：`Magic`（主 App）+ `MagicWidget`（Widget Extension）双 target，共享 App Group `group.com.othric.magic`
- `CuttingMat` 渲染引擎：7 个 Layer（Background / Vignette / Grid / Border / Tick / Arc / Number）+ 纯函数渲染器 + 缓存
- SwiftData：`MatDocument` 持久化，`MatStore` 列表 CRUD
- Home（mat 列表 / 缩略图）+ Editor（全屏画布 + 工具栏 + 换色 8 主题）两页 NavigationStack 路由
- `WidgetBridge` 经 App Group 桥接，换色 / 退出实时刷新 Widget
- 产品名仅在 `AppConfig.productName`，绘制数值全部走 design tokens（无裸数字）
