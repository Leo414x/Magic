# Magic — 项目说明（Claude 入口文档）

> 本文件是**项目导航 + 跨会话状态**。完整技术规格见 [TECH_MVP.md](TECH_MVP.md)。

## 项目背景
Magic 是一个 sticker collage iOS 工具：用户从照片提取主体作为 sticker，在 cutting mat 画布上排版，最终作为 Home Screen Widget 展示。产品名 "Magic" 为暂定名，仅出现在 `AppConfig.productName`，UI 一律引用。

- 平台：iOS 17+，SwiftUI + SwiftData + WidgetKit
- 工程：**XcodeGen** 管理 —— `project.yml` 是唯一真相源；**改/增/删文件后必须先 `xcodegen generate` 再 build**
- 两个 target：`Magic`（主 App）+ `MagicWidget`（Widget Extension），共享 App Group `group.com.othric.magic`
- 构建/验证：`xcodebuild -project Magic.xcodeproj -scheme Magic -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build CODE_SIGNING_ALLOWED=NO build`

## 当前状态（2026-06-17）
Phase 1 已完成并对齐 Figma：
- Home（mat 列表）/ Editor（单 mat 画布 + 换色）/ SwiftData 持久化 / Widget 同步
- 渲染：风格化架构（`MatStyle` → `MatStyleRegistry` → `GridMatStyle`，`MatRenderer` 驱动），网格对齐 **Figma 节点 11:872**：主亮线在 col 4/9/14/19 + 中线 row 4，明线透明度 0.8，最外圈内部线交给外框
- app 外围背景白色 + 浅色 UI（mat 本身仍是主题色）
- 近期修复：widget 黑边（图铺满 containerBackground）、编辑器 `+` 调起系统相册（PhotosPicker）、弧线裁到最底部水平线、外框 2.2、R10 标签贴 R10 弧线 2px

待办（Phase 2+）：sticker 主体提取 / 拖拽缩放旋转、撕纸边缘、收藏 Drawer、Wand 自动装饰、CloudKit 协作。选中照片目前暂存 `pickedPhoto` 未落地。

## 技术规格
完整规格（构建顺序、各文件实现、背景风格扩展、Figma 同步流程、验收标准）见 **[TECH_MVP.md](TECH_MVP.md)**。

> ⚠️ TECH_MVP.md 是**规格快照 / 参考文档**，不再要求每次代码改动都回头逐行同步。**源码以仓库为准。** 仅当架构层面有变化时才更新它。

## 多设备协同（multi-machine setup）
- 用 **git** 同步，**不要用 iCloud**（iCloud 会同步 `.xcodeproj` / `DerivedData` 造成冲突与半同步状态）。
- 远程仓库：https://github.com/Leo414x/Magic
- 换机流程：`git pull` → `xcodegen generate` → `xcodebuild`（或打开生成的 `Magic.xcodeproj`）。
- 不入库（`.gitignore`）：`Magic.xcodeproj/`（由 project.yml 生成）、`build/`、`DerivedData/`、`_verify/`（本地渲染验证产物）、`.DS_Store`。

## 跨会话写作约定
- 每次会话有实质进展后，更新本文件「当前状态」（日期 + 一句话简述），作为下次会话的起点。
- 架构性 / 规格性变更写入 TECH_MVP.md；日常小改不强制同步。
- git commit message 用于跨会话、跨设备追踪进度，写清楚改了什么。
