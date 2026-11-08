# 替换设置图标为经典主题图标

作者：newbieeming

仅维护将默认设置图标替换为经典主题动态图标的 KernelSU 模块。

## 构建

使用 Windows PowerShell 5.1 或 PowerShell 7，在项目目录运行：

```powershell
./build-icons.ps1
```

安装包输出：`dist/Classic-Settings-Icon-v1.1.zip`。

## 文件

- `build-icons.ps1`：构建脚本及模块元数据、安装脚本和使用说明。
- `resources/classic-settings-icons.zip`：仅包含经典设置图标的分层动画、配置和回退图片。
- `resources/default/icons`、`resources/default/dynamicicons`：构建覆盖包所需的原始图标资源。压缩包是整体覆盖，因此保留其中其他图标的原始内容。
- `dist/classic-settings-module`：生成的模块目录。
- `dist/Classic-Settings-Icon-v1.1.zip`：可安装模块。

## 使用

在 KernelSU 中安装 ZIP，启用支持系统文件覆盖的元模块，选择默认主题图标后重启。
设置图标的旋转动画在从设置返回桌面时触发。禁用或卸载模块后重启即可恢复。

模块覆盖默认图标资源文件；不同系统的资源格式和动画加载方式可能不同，尚未验证跨系统显示效果。
请勿通过清除桌面数据刷新图标，以免丢失桌面布局。
