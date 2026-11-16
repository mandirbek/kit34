$key = [System.Text.Encoding]::ASCII.GetBytes("goblingun")
Get-ChildItem "$PSScriptRoot\*.xml" -Recurse | ForEach-Object {
    $datPath = [System.IO.Path]::ChangeExtension($_.FullName, ".dat")
    if (-not (Test-Path $datPath) -or $_.LastWriteTime -gt (Get-Item $datPath).LastWriteTime) {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
        if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
            $bytes = [byte[]](0xEF, 0xBB, 0xBF) + $bytes
        }
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            $bytes[$i] = $bytes[$i] -bxor $key[$i % $key.Length]
        }
        [System.IO.File]::WriteAllBytes($datPath, $bytes)
        Write-Host "Упакован: $($_.Name) -> $([System.IO.Path]::GetFileName($datPath))" -ForegroundColor Green
    }
}