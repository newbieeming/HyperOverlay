# Overlay

KernelSU 系统资源覆盖模块集合，每个模块在独立目录内维护。

## 模块

- [ClassicSettingsIcon](ClassicSettingsIcon/README.md)：替换设置图标为经典主题动态图标。

## 构建

使用 PowerShell 7，在仓库根目录运行：

```powershell
./ClassicSettingsIcon/build-icons.ps1
```

安装包输出到 `ClassicSettingsIcon/dist/`。

Git 记录构建脚本、说明和必要资源；`dist/` 为可重新生成的构建产物，不纳入版本管理。
新增模块时创建独立目录，并在此列出其用途和构建入口。
