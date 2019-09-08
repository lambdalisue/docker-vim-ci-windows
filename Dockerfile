# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2016
MAINTAINER lambdalisue <lambdalisue@hashnote.net>

# Use powershell in RUN
SHELL ["powershell", "-Command", "$ErrorActionPreference='Stop'; $ConfirmPreference='None'; $VerbosePreference='Continue'; "]

# Use GMT Standard Time instead of Pacific Stanard Time
RUN Set-TimeZone 'GMT Standard Time'

# Overwrite system 'chcp' while Windows container provides only CP 65001
# and that cause 'invalid code page' error during channel build.
# https://social.msdn.microsoft.com/Forums/en-US/0c4a2452-efd5-4e39-bd58-9748201e1670/codepages-in-servercorenanoserver?forum=windowscontainers
COPY ./assets/chcp.bat C:\Patch\chcp.bat
RUN $env:PATH = 'C:\Patch;' + $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); `
    Get-Command chcp | Format-List

# Download a particular version of Vim
ARG VERSION=latest
ARG ARCH=x64
COPY ./assets/install_vim.ps1 .
RUN ./install_vim.ps1 ${env:VERSION} ${env:ARCH}; `
    Remove-Item install_vim.ps1

# Restore SHELL
SHELL ["cmd"]

VOLUME C:\volume
WORKDIR C:\volume
ENTRYPOINT ["vim"]
CMD []
