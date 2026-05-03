# MacMouseCopyPaste

一个极小的 macOS 菜单栏工具，把鼠标中键映射为复制，把鼠标五键映射为粘贴。
A tiny macOS menu bar utility that maps middle click to copy and mouse button 5 to paste.

## 功能
## Features

- 鼠标中键触发 `Command+C`。
- Middle click sends `Command+C`.

- 鼠标五键触发 `Command+V`。
- Mouse button 5 sends `Command+V`.

- 常驻菜单栏，没有主窗口。
- Lives in the menu bar with no main window.

- 菜单栏使用固定宽度图标，不占用文字空间。
- The menu bar item uses a fixed-width icon instead of a text label.

- 不依赖 Mac Mouse Fix、Karabiner 或其它鼠标管理软件。
- Does not depend on Mac Mouse Fix, Karabiner, or any other mouse manager.

## 下载
## Download

- 从 GitHub Releases 下载 `MouseCopyPaste.app.zip`。
- Download `MouseCopyPaste.app.zip` from GitHub Releases.

- 解压后把 `MouseCopyPaste.app` 放到 `/Applications` 或任意你喜欢的位置。
- Unzip it and place `MouseCopyPaste.app` in `/Applications` or any location you prefer.

## 使用
## Usage

- 第一次打开后，macOS 会要求授予辅助功能权限。
- On first launch, macOS will ask for Accessibility permission.

- 如果没有自动弹出权限窗口，请打开 `System Settings > Privacy & Security > Accessibility`，手动允许 `MouseCopyPaste`。
- If the permission prompt does not appear, open `System Settings > Privacy & Security > Accessibility` and allow `MouseCopyPaste` manually.

- 授权后如果没有立刻生效，请退出并重新打开 App。
- If it does not work immediately after granting permission, quit and reopen the app.

## 辅助功能授权问题
## Accessibility Permission Troubleshooting

- 建议把 App 放到 `/Applications` 后再授权，不要直接从临时解压目录运行。
- Put the app in `/Applications` before granting permission; avoid running it from a temporary unzip folder.

- 如果升级后反复要求授权，请先从辅助功能列表里移除旧的 `MouseCopyPaste`，再重新添加新版 App。
- If permission is requested repeatedly after an update, remove the old `MouseCopyPaste` entry from Accessibility, then add the new app again.

- `v1.2.0` 开始 release 包使用稳定本地签名身份，不再使用 ad-hoc 签名。
- Starting with `v1.2.0`, release builds use a stable local signing identity instead of ad-hoc signing.

- 由于没有 Apple Developer ID，本项目仍然不是 Apple 公证包，首次打开可能仍需在系统安全设置中允许。
- Because there is no Apple Developer ID, this project is still not Apple-notarized, so first launch may still need approval in macOS security settings.

## 从源码构建
## Build From Source

```bash
./scripts/verify_mapping.sh
swift build
./scripts/package_app.sh
```

- 打包后的 App 会生成在 `dist/MouseCopyPaste.app`。
- The packaged app is generated at `dist/MouseCopyPaste.app`.

- 为了让 macOS 辅助功能授权在本机反复构建后更稳定，可以先创建本地签名身份。
- To keep macOS Accessibility permission more stable across local rebuilds, create a local signing identity first.

```bash
./scripts/create_local_signing_identity.sh
./scripts/package_app.sh
```

- 如果没有本地签名身份，脚本会回退到 ad-hoc 签名。
- If no local signing identity exists, the package script falls back to ad-hoc signing.

## 技术说明
## Technical Notes

- App 使用 Swift、AppKit 和 CoreGraphics 编写。
- The app is written with Swift, AppKit, and CoreGraphics.

- 鼠标事件通过 `CGEventTap` 监听。
- Mouse events are observed with `CGEventTap`.

- 中键通常是 CoreGraphics button number `2`。
- Middle click is usually CoreGraphics button number `2`.

- 鼠标五键通常是 CoreGraphics button number `4`。
- Mouse button 5 is usually CoreGraphics button number `4`.

- 如果你的鼠标侧键编号不同，可以修改 `Sources/MouseCopyPasteCore/MouseShortcutMapping.swift`。
- If your mouse reports a different side-button number, edit `Sources/MouseCopyPasteCore/MouseShortcutMapping.swift`.

## 许可证
## License

- 本项目使用 MIT License。
- This project is licensed under the MIT License.
