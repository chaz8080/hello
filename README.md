# Hello

## Overview

This project serves as a base to understand and build a simple application deployment via distillery. Since this deployment needs to be built on a linux system, the use of docker simplifies the process further. This project assumes the developer is using Windows 10.

## Prereqs

Install Docker

```cli
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco install -y docker-desktop
```

## Build a release

First build the image that will contain the OTP release:

```cli
docker build . -t elixir-app
```

Run your release:

```cli
docker run --rm -it -p 4000:4001 -e PORT=4001 elixir-app
```