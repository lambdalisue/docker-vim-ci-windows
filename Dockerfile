# escape=`
FROM microsoft/windowsservercore
MAINTAINER lambdalisue <lambdalisue@hashnote.net>

# Use powershell in RUN
SHELL ["powershell", "-Command", "$ErrorActionPreference='Stop'; $ConfirmPreference='None'; $VerbosePreference='Continue'; "]

# Use GMT Standard Time instead of Pacific Stanard Time
RUN Set-TimeZone 'GMT Standard Time'

# Overwrite system 'chcp' while Windows container provides only CP 65001
# and that cause 'invalid code page' error during channel build.
# https://social.msdn.microsoft.com/Forums/en-US/0c4a2452-efd5-4e39-bd58-9748201e1670/codepages-in-servercorenanoserver?forum=windowscontainers
COPY ./chcp.bat C:\Patch\chcp.bat
RUN $env:PATH = 'C:\Patch;' + $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); `
    Get-Command chcp | Format-List

# Download a particular version of Vim
ARG ARCH=x64
ARG VERSION=8.1.0526
RUN $URL = "\"https://github.com/vim/vim-win32-installer/releases/download/v${env:VERSION}/gvim_${env:VERSION}_${env:ARCH}.zip\""; `
    $OUT = [System.IO.Path]::GetTempFileName() + '.zip'; `
    [System.Net.ServicePointManager]::SecurityProtocol = @( `
        [Net.SecurityProtocolType]::Tls, `
        [Net.SecurityProtocolType]::Tls11, `
        [Net.SecurityProtocolType]::Tls12 `
    ); `
    Invoke-WebRequest `
        -UseBasicParsing `
        -OutFile $OUT `
        -Uri $URL; `
    [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') > $null; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory($OUT, 'C:\ProgramData'); `
    Remove-Item $OUT; `
    $env:PATH = (Get-ChildItem 'C:\ProgramData\vim\vim*' | Select -First 1).ToString() + ';' + $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); `
    Get-Command vim | Format-List

VOLUME C:\volume
WORKDIR C:\volume
ENTRYPOINT ["vim"]
CMD []
