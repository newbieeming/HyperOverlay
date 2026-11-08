$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = $PSScriptRoot
$out = Join-Path $root 'dist/classic-settings-module'
$theme = Join-Path $out 'system/product/media/theme'
$source = Join-Path $root 'resources/classic-settings-icons.zip'
New-Item -ItemType Directory -Force "$theme/default", "$theme/miui_mod_icons/dynamic/com.android.settings" | Out-Null
$classic = [IO.Compression.ZipFile]::OpenRead($source)
try {
    # Keep every other icon and default transform setting byte-for-byte.
    foreach ($archive in @('icons', 'dynamicicons')) {
        $target = "$theme/default/$archive"
        if (Test-Path $target) { Remove-Item -LiteralPath $target }
        $original = [IO.Compression.ZipFile]::OpenRead("$root/resources/default/$archive")
        $zip = [IO.Compression.ZipFile]::Open($target, [IO.Compression.ZipArchiveMode]::Create)
        try {
            $entries = @($classic.Entries | Where-Object {
                $_.Name -ne '' -and (
                    $_.FullName.StartsWith('layer_animating_icons/com.android.settings/') -or
                    $_.FullName -match '^res/drawable-[^/]+/com\.android\.settings(?:\.png|/)'
                )
            })
            $replacementNames = @($entries | ForEach-Object FullName)
            $preserved = @($original.Entries | Where-Object { $_.Name -ne '' -and $_.FullName -notin $replacementNames })
            foreach ($entry in @($preserved) + @($entries)) {
                $new = $zip.CreateEntry($entry.FullName)
                $inputStream = $entry.Open()
                $outputStream = $new.Open()
                try { $inputStream.CopyTo($outputStream) }
                finally { $inputStream.Dispose(); $outputStream.Dispose() }
            }
        } finally { $zip.Dispose(); $original.Dispose() }
    }
    $static = $classic.GetEntry('res/drawable-xxhdpi/com.android.settings.png')
    [IO.Compression.ZipFileExtensions]::ExtractToFile($static, "$theme/miui_mod_icons/com.android.settings.png", $true)
    foreach ($layer in 0, 1) {
        $entry = $classic.GetEntry("res/drawable-xxhdpi/com.android.settings/$layer.png")
        [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, "$theme/miui_mod_icons/dynamic/com.android.settings/$layer.png", $true)
    }
} finally { $classic.Dispose() }
$utf8 = [Text.UTF8Encoding]::new($false)
function Write-Lf($name, $content) {
    [IO.File]::WriteAllText((Join-Path $out $name), ($content -replace "`r`n", "`n") + "`n", $utf8)
}
Write-Lf 'module.prop' @'
id=classic_settings_icon
name=替换设置图标为经典主题图标
version=1.1
versionCode=2
author=newbieeming
description=将默认设置图标替换为经典主题动态图标，包含分层图标、旋转动画及静态回退资源。安装后重启生效，禁用或卸载后重启恢复。
'@
Write-Lf 'customize.sh' @'
#!/system/bin/sh
[ "$KSU" = true ] || abort "请使用 KernelSU 安装"
[ -d /data/adb/metamodule ] || abort "请先安装并启用支持系统文件覆盖的元模块"
[ ! -f /data/adb/metamodule/disable ] || abort "系统文件覆盖元模块已禁用"
[ -f /product/media/theme/default/dynamicicons ] || abort "系统缺少所需的默认动态图标资源路径"
[ -f /product/media/theme/default/icons ] || abort "系统缺少所需的默认图标资源路径"
ui_print "替换设置图标为经典主题图标"
ui_print "作者：newbieeming"
ui_print "包含经典分层动画、JSON 配置及静态回退图片"
ui_print "请在主题中选择默认图标，安装后重启"
ui_print "禁用或卸载本模块后重启即可恢复"
set_perm_recursive "$MODPATH" 0 0 0755 0644
'@
Write-Lf 'README.txt' @'
替换设置图标为经典主题图标
作者：newbieeming

来源：系统预置经典主题图标资源。
包含：两层动态图标、Folme 旋转动画、JSON、配置以及静态回退图片。
动画在从设置返回桌面时触发，不是常驻旋转。

安装：KernelSU 模块页选择 ZIP，启用支持系统文件覆盖的元模块，重启手机。
主题图标应选择“默认”；其他主题自己的图标可能优先于默认覆盖。
桌面若仍显示旧图标，可在主题中重新应用默认图标后重启。
不要清除桌面数据，以免丢失桌面布局。

卸载：KernelSU 禁用或卸载本模块，再重启即可恢复系统原始资源。
不修改 /data/system/theme，不替换整个主题。
本模块使用标准 system/product 目录，由现有元模块执行 systemless 覆盖。

验证状态：已校验压缩包、资源完整性和非设置图标内容保留。
尚未安装、重启及真机验证桌面加载与动画显示，安装后需确认效果。
'@
$archivePath = Join-Path $root 'dist/Classic-Settings-Icon-v1.1.zip'
if (Test-Path $archivePath) { Remove-Item -LiteralPath $archivePath }
# ZipFile uses '/' entry separators; Compress-Archive may use Windows separators.
$package = [IO.Compression.ZipFile]::Open($archivePath, [IO.Compression.ZipArchiveMode]::Create)
try {
    Get-ChildItem $out -Recurse -File | ForEach-Object {
        $relative = [IO.Path]::GetRelativePath($out, $_.FullName).Replace('\', '/')
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($package, $_.FullName, $relative) | Out-Null
    }
} finally { $package.Dispose() }
Get-FileHash $archivePath
