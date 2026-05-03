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

## 从源码构建
## Build From Source

```bash
./scripts/verify_mapping.sh
swift build
./scripts/package_app.sh
```

- 打包后的 App 会生成在 `dist/MouseCopyPaste.app`。
- The packaged app is generated at `dist/MouseCopyPaste.app`.

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
