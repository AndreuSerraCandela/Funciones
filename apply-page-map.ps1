$map = @{}
for ($i = 0; $i -le 71; $i++) {
  $old = '7001' + (105 + $i).ToString()
  $new = (50049 + $i).ToString()
  $map[$old] = $new
}
$ids = $map.Keys | Sort-Object { [int]$_ } -Descending
Get-ChildItem -Path "src" -Recurse -Include *.al,*.Al | ForEach-Object {
  $content = Get-Content $_.FullName -Raw -Encoding UTF8
  $changed = $false
  foreach ($old in $ids) {
    $new = $map[$old]
    if ($content -match [regex]::Escape($old)) {
      $content = $content -replace [regex]::Escape($old), $new
      $changed = $true
    }
  }
  if ($changed) {
    Set-Content $_.FullName -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Updated: $($_.FullName)"
  }
}

# 50xxx: orden para no pisar: 50003->50001, luego 50004->50002, luego 50012->50003
$map50 = @(@{old='50003';new='50001'}, @{old='50004';new='50002'}, @{old='50012';new='50003'})
Get-ChildItem -Path "src" -Recurse -Include *.al,*.Al | ForEach-Object {
  $content = Get-Content $_.FullName -Raw -Encoding UTF8
  $changed = $false
  foreach ($pair in $map50) {
    if ($content -match [regex]::Escape($pair.old)) {
      $content = $content -replace [regex]::Escape($pair.old), $pair.new
      $changed = $true
    }
  }
  if ($changed) {
    Set-Content $_.FullName -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Updated 50xxx: $($_.FullName)"
  }
}
