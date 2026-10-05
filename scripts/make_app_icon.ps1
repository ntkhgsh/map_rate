# MapRate アプリアイコン生成（ネイビー背景＋地球の経緯線、白いピン、コーラルの円に白抜きの € $ ¥ £）
# 使い方: powershell -ExecutionPolicy Bypass -File scripts\make_app_icon.ps1

Add-Type -AssemblyName System.Drawing

function F([double]$v) { return [single]$v }

function New-MapRateIcon([int]$size) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

  # 背景：左上の青から右下の深いネイビーへ流れる斜めグラデーション
  $bgRect = New-Object System.Drawing.RectangleF 0, 0, $size, $size
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush ($bgRect,
    [System.Drawing.Color]::FromArgb(255, 24, 118, 196),
    [System.Drawing.Color]::FromArgb(255, 9, 36, 78),
    ([System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal))
  $g.FillRectangle($bg, $bgRect)
  $bg.Dispose()

  # ピンの寸法（円の中心・半径・先端）
  $cx = $size / 2.0
  $r = $size * 0.29
  $cy = $size * 0.41
  $tipY = $size * 0.85

  # 背景の地球（経線・緯線）。ごく薄くして、小さいサイズでは主張しないようにする
  $globeR = $r * 1.30
  $globePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(34, 255, 255, 255)), (F ($size * 0.006))
  $g.DrawEllipse($globePen, (F ($cx - $globeR)), (F ($cy - $globeR)), (F ($globeR * 2)), (F ($globeR * 2)))
  foreach ($k in @(0.55, 1.0)) {
    # 経線：横幅を縮めた楕円
    $ew = $globeR * $k
    $g.DrawEllipse($globePen, (F ($cx - $ew)), (F ($cy - $globeR)), (F ($ew * 2)), (F ($globeR * 2)))
  }
  foreach ($lat in @(-0.5, 0.0, 0.5)) {
    # 緯線：円の内側に収まる長さの水平線
    $yy = $cy + $globeR * $lat
    $half = $globeR * [Math]::Sqrt(1.0 - $lat * $lat)
    $g.DrawLine($globePen, (F ($cx - $half)), (F $yy), (F ($cx + $half)), (F $yy))
  }
  $globePen.Dispose()

  # 先端下の接地影
  $shadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(90, 4, 20, 45))
  $sw = $size * 0.20
  $sh = $size * 0.04
  $g.FillEllipse($shadowBrush, (F ($cx - $sw / 2.0)), (F ($tipY - $sh * 0.5)), (F $sw), (F $sh))
  $shadowBrush.Dispose()

  # しずく形：先端から円へ引いた接線と、円弧で1本の輪郭にする（つなぎ目のくびれを防ぐ）
  $d = $tipY - $cy
  $theta = [Math]::Acos($r / $d)            # 真下方向から接点までの角度
  $thetaDeg = $theta * 180.0 / [Math]::PI
  $pin = New-Object System.Drawing.Drawing2D.GraphicsPath
  # GDI+ の角度は右が0度・時計回り。左の接点(90+θ)から上側を回って右の接点(90-θ)まで
  $pin.AddArc((F ($cx - $r)), (F ($cy - $r)), (F ($r * 2)), (F ($r * 2)),
    (F (90.0 + $thetaDeg)), (F (360.0 - 2.0 * $thetaDeg)))
  $pin.AddLine((F ($cx + $r * [Math]::Sin($theta))), (F ($cy + $r * [Math]::Cos($theta))), (F $cx), (F $tipY))
  $pin.CloseFigure()

  # ピンの落ち影（少し下にずらした半透明の同形）で浮いて見せる
  $dropMatrix = New-Object System.Drawing.Drawing2D.Matrix
  $dropMatrix.Translate(0, (F ($size * 0.018)))
  $drop = $pin.Clone()
  $drop.Transform($dropMatrix)
  $dropBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(70, 4, 20, 45))
  $g.FillPath($dropBrush, $drop)
  $dropBrush.Dispose()
  $drop.Dispose()
  $dropMatrix.Dispose()

  # ピン本体：わずかに上が明るい白のグラデーション
  $pinBounds = $pin.GetBounds()
  $pinBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush ($pinBounds,
    [System.Drawing.Color]::FromArgb(255, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(255, 226, 236, 246),
    ([System.Drawing.Drawing2D.LinearGradientMode]::Vertical))
  $g.FillPath($pinBrush, $pin)
  $pinBrush.Dispose()
  $pin.Dispose()

  # ピンの頭にコーラルの円（記号の土台）
  $rIn = $r * 0.80
  $diskRect = New-Object System.Drawing.RectangleF (F ($cx - $rIn)), (F ($cy - $rIn)), (F ($rIn * 2)), (F ($rIn * 2))
  $diskBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush ($diskRect,
    [System.Drawing.Color]::FromArgb(255, 255, 138, 101),
    [System.Drawing.Color]::FromArgb(255, 226, 82, 58),
    ([System.Drawing.Drawing2D.LinearGradientMode]::Vertical))
  $g.FillEllipse($diskBrush, $diskRect)
  $diskBrush.Dispose()

  # 通貨記号 2x2（€ $ / ¥ £）を白抜きで置く
  # 文字の外枠を実測して、各マスの中心へぴったり置く（フォントの余白でずれない）
  $markBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
  $family = New-Object System.Drawing.FontFamily 'Bahnschrift SemiBold'
  $style = [int][System.Drawing.FontStyle]::Regular
  $emSize = $rIn * 0.66
  $offset = $rIn * 0.38                     # 円の中心から各記号の中心までの距離
  $symbols = @(
    @{ t = [string][char]0x20AC; dx = -1; dy = -1 }, # €
    @{ t = '$';                  dx =  1; dy = -1 },
    @{ t = [string][char]0x00A5; dx = -1; dy =  1 }, # ¥
    @{ t = [string][char]0x00A3; dx =  1; dy =  1 }  # £
  )
  foreach ($s in $symbols) {
    $glyph = New-Object System.Drawing.Drawing2D.GraphicsPath
    # 輪郭が重なるフォントでも穴が抜けないよう、重なり部分も塗る方式にする
    $glyph.FillMode = [System.Drawing.Drawing2D.FillMode]::Winding
    $glyph.AddString($s.t, $family, $style, (F $emSize), (New-Object System.Drawing.PointF 0, 0), [System.Drawing.StringFormat]::GenericTypographic)
    $b = $glyph.GetBounds()
    $tx = $cx + $s.dx * $offset - ($b.X + $b.Width / 2.0)
    $ty = $cy + $s.dy * $offset - ($b.Y + $b.Height / 2.0)
    $m = New-Object System.Drawing.Drawing2D.Matrix
    $m.Translate((F $tx), (F $ty))
    $glyph.Transform($m)
    $g.FillPath($markBrush, $glyph)
    $m.Dispose()
    $glyph.Dispose()
  }

  $family.Dispose()
  $markBrush.Dispose()
  $g.Dispose()
  return $bmp
}

function Save-Png([System.Drawing.Bitmap]$bmp, [string]$path) {
  $dir = Split-Path $path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  if (Test-Path $path) { Remove-Item $path -Force }
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Save-Resized([System.Drawing.Bitmap]$src, [int]$size, [string]$path, [bool]$opaque = $false) {
  $fmt = if ($opaque) {
    [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
  } else {
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  }
  $b = New-Object System.Drawing.Bitmap $size, $size, $fmt
  $gg = [System.Drawing.Graphics]::FromImage($b)
  $gg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $gg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  if ($opaque) {
    $gg.Clear([System.Drawing.Color]::FromArgb(255, 21, 120, 181))
  } else {
    $gg.Clear([System.Drawing.Color]::Transparent)
  }
  $gg.DrawImage($src, 0, 0, $size, $size)
  $gg.Dispose()
  Save-Png $b $path
  $b.Dispose()
}

# scripts/ の親がリポジトリルート
$root = Resolve-Path (Join-Path $PSScriptRoot '..')

$master = New-MapRateIcon 1024
Save-Png $master (Join-Path $root 'assets\app_icon_source_1024.png')
Save-Resized $master 512 (Join-Path $root 'assets\play_store_icon_512.png') $true
Save-Resized $master 512 (Join-Path $root 'assets\app_icon.png') $true

$android = @{
  'mipmap-mdpi' = 48
  'mipmap-hdpi' = 72
  'mipmap-xhdpi' = 96
  'mipmap-xxhdpi' = 144
  'mipmap-xxxhdpi' = 192
}
foreach ($kv in $android.GetEnumerator()) {
  Save-Resized $master $kv.Value (Join-Path $root ("android\app\src\main\res\{0}\ic_launcher.png" -f $kv.Key))
}

$splash = @{
  'drawable' = 288
  'drawable-mdpi' = 96
  'drawable-hdpi' = 144
  'drawable-xhdpi' = 192
  'drawable-xxhdpi' = 288
  'drawable-xxxhdpi' = 384
}
foreach ($kv in $splash.GetEnumerator()) {
  Save-Resized $master $kv.Value (Join-Path $root ("android\app\src\main\res\{0}\splash_icon.png" -f $kv.Key))
}

$iosDir = Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
$ios = @{
  'Icon-App-1024x1024@1x.png' = 1024
  'Icon-App-20x20@1x.png' = 20
  'Icon-App-20x20@2x.png' = 40
  'Icon-App-20x20@3x.png' = 60
  'Icon-App-29x29@1x.png' = 29
  'Icon-App-29x29@2x.png' = 58
  'Icon-App-29x29@3x.png' = 87
  'Icon-App-40x40@1x.png' = 40
  'Icon-App-40x40@2x.png' = 80
  'Icon-App-40x40@3x.png' = 120
  'Icon-App-60x60@2x.png' = 120
  'Icon-App-60x60@3x.png' = 180
  'Icon-App-76x76@1x.png' = 76
  'Icon-App-76x76@2x.png' = 152
  'Icon-App-83.5x83.5@2x.png' = 167
}
foreach ($kv in $ios.GetEnumerator()) {
  Save-Resized $master $kv.Value (Join-Path $iosDir $kv.Key) $true
}

$desk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'MapRate_PlayIcon_512.png'
Save-Resized $master 512 $desk $true

# サイト用（日本語パスがあるので -LiteralPath で判定する）
$mr = 'C:\Users\ntkhg\OneDrive\04_WEB関係\yatralabs\mr'
if (Test-Path -LiteralPath $mr) {
  Save-Resized $master 512 (Join-Path $mr 'play_icon_512.png') $true
  Save-Resized $master 192 (Join-Path $mr 'web-icon-192.png')
  Save-Resized $master 180 (Join-Path $mr 'apple-touch-icon.png')
  Save-Resized $master 32 (Join-Path $mr 'favicon-32.png')
  Write-Host "web=$mr"
} else {
  Write-Host "WARN: website folder not found: $mr"
}

$master.Dispose()
Write-Host "OK: MapRate icon with EUR/USD/JPY/GBP marks"
Write-Host "play=$((Join-Path $root 'assets\play_store_icon_512.png'))"
Write-Host "desk=$desk"
