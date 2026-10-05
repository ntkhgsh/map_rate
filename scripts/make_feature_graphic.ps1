# Google Play フィーチャーグラフィック（1024x500・アルファなし PNG）生成
# 先に scripts\make_app_icon.ps1 を実行して、assets\play_store_icon_512.png を最新にしておく
# 使い方: powershell -ExecutionPolicy Bypass -File scripts\make_feature_graphic.ps1

Add-Type -AssemblyName System.Drawing

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$W = 1024
$H = 500

$bmp = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# 背景：アイコンと同系の青グラデーション
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush ((New-Object System.Drawing.Rectangle 0, 0, $W, $H),
  [System.Drawing.Color]::FromArgb(255, 24, 118, 196),
  [System.Drawing.Color]::FromArgb(255, 9, 36, 78),
  ([System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal))
$g.FillRectangle($bg, 0, 0, $W, $H)
$bg.Dispose()

# 地図アプリらしさを出す薄いグリッド（装飾）
$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(22, 255, 255, 255)), 1
for ($x = 0; $x -lt $W; $x += 64) { $g.DrawLine($gridPen, $x, 0, $x, $H) }
for ($y = 0; $y -lt $H; $y += 64) { $g.DrawLine($gridPen, 0, $y, $W, $y) }
$gridPen.Dispose()

# 左：角丸のアプリアイコン
$icon = New-Object System.Drawing.Bitmap (Join-Path $root 'assets\play_store_icon_512.png')
$iconSize = 340
$ix = 80
$iy = [int](($H - $iconSize) / 2)
$radius = 72
function New-RoundRect([int]$x, [int]$y, [int]$w, [int]$h, [int]$rr) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddArc($x, $y, $rr * 2, $rr * 2, 180, 90)
  $p.AddArc($x + $w - $rr * 2, $y, $rr * 2, $rr * 2, 270, 90)
  $p.AddArc($x + $w - $rr * 2, $y + $h - $rr * 2, $rr * 2, $rr * 2, 0, 90)
  $p.AddArc($x, $y + $h - $rr * 2, $rr * 2, $rr * 2, 90, 90)
  $p.CloseFigure()
  return $p
}
$shadowPath = New-RoundRect ($ix + 6) ($iy + 10) $iconSize $iconSize $radius
$shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(70, 0, 30, 60))
$g.FillPath($shadow, $shadowPath)
$shadow.Dispose()
$shadowPath.Dispose()
$clip = New-RoundRect $ix $iy $iconSize $iconSize $radius
$g.SetClip($clip)
$g.DrawImage($icon, $ix, $iy, $iconSize, $iconSize)
$g.ResetClip()
$ring = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 255, 255, 255)), 3
$g.DrawPath($ring, $clip)
$ring.Dispose()
$clip.Dispose()
$icon.Dispose()

# 右：アプリ名とキャッチコピー
$titleFont = New-Object System.Drawing.Font 'Segoe UI', 88, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
$tagFont = New-Object System.Drawing.Font 'Segoe UI', 32, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$shadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(90, 0, 40, 70))
$tagBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245, 235, 245, 255))
$textX = 480
$titleY = 150
$tagY = 262
$g.DrawString('MapRate', $titleFont, $shadowBrush, $textX + 2, $titleY + 3)
$g.DrawString('MapRate', $titleFont, [System.Drawing.Brushes]::White, $textX, $titleY)
$g.DrawString('World map FX converter', $tagFont, $tagBrush, $textX + 4, $tagY)
$titleFont.Dispose()
$tagFont.Dispose()
$shadowBrush.Dispose()
$tagBrush.Dispose()
$g.Dispose()

function Save-Png24([System.Drawing.Bitmap]$src, [string]$path) {
  if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
  $src.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

Save-Png24 $bmp (Join-Path $root 'assets\play_feature_graphic_1024x500.png')
Save-Png24 $bmp (Join-Path ([Environment]::GetFolderPath('Desktop')) 'MapRate_FeatureGraphic_1024x500.png')
# サイト用（日本語パスがあるので -LiteralPath で判定する）
$mr = 'C:\Users\ntkhg\OneDrive\04_WEB関係\yatralabs\mr'
if (Test-Path -LiteralPath $mr) {
  Save-Png24 $bmp (Join-Path $mr 'play_feature_graphic_1024x500.png')
  Write-Host "web=$mr"
} else {
  Write-Host "WARN: website folder not found: $mr"
}
$bmp.Dispose()
Write-Host 'OK: feature graphic 1024x500'
