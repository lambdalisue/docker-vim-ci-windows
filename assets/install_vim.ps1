Param(
    [String]$Version,
    [String]$Arch = 'x64'
)
# Enable SSL/TLS
[System.Net.ServicePointManager]::SecurityProtocol = @(
    [Net.SecurityProtocolType]::Tls,
    [Net.SecurityProtocolType]::Tls11,
    [Net.SecurityProtocolType]::Tls12
)

if ($Version -eq "latest") {
    $r = Invoke-WebRequest -UseBasicParsing -URI "http://vim-jp.org/redirects/vim/vim-win32-installer/latest/${arch}"
    $url = $r.Links[0].href
} else {
    $url = "https://github.com/vim/vim-win32-installer/releases/download/v${version}/gvim_${version}_${arch}.zip"
}
Write-Host "Version: $version"
Write-Host "Arch:    $arch"
Write-Host "URL:     $url"

$out = [System.IO.Path]::GetTempFileName() + '.zip'

Invoke-WebRequest -UseBasicParsing -OutFile $out -Uri $url
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') > $null
[System.IO.Compression.ZipFile]::ExtractToDirectory($out, 'C:\ProgramData')
Remove-Item $out

$env:PATH = (Get-ChildItem 'C:\ProgramData\vim\vim*' | Select -First 1).ToString() + ';' + $env:PATH; `
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); `
Get-Command vim | Format-List
