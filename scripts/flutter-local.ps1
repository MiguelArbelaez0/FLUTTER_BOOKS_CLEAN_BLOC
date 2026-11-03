param(
    [string]$JdkPath,
    [Parameter(Mandatory = $true)]
    [string[]]$FlutterArguments
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $JdkPath) {
    $candidate = Get-ChildItem -LiteralPath (Join-Path $projectRoot '.tooling/jdk17') -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin/java.exe') } |
        Select-Object -First 1
    if (-not $candidate) { throw 'Provide -JdkPath pointing to a portable JDK 17, or extract it under .tooling/jdk17/.' }
    $JdkPath = $candidate.FullName
}
$JdkPath = (Resolve-Path -LiteralPath $JdkPath).Path
if (-not (Test-Path -LiteralPath (Join-Path $JdkPath 'bin/java.exe'))) {
    throw 'The JDK directory must contain bin/java.exe.'
}
$flutterCommand = (Get-Command flutter -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$configDirectory = Join-Path $projectRoot '.tooling/flutter-config'
New-Item -ItemType Directory -Force -Path $configDirectory | Out-Null
$settings = @{ 'jdk-dir' = $JdkPath }
[System.IO.File]::WriteAllText(
    (Join-Path $configDirectory '.flutter_settings'),
    ($settings | ConvertTo-Json),
    [System.Text.UTF8Encoding]::new($false)
)

# Only this process and its children see the isolated settings and Java runtime.
$previousAppData = $env:APPDATA
$previousJavaHome = $env:JAVA_HOME
$previousPath = $env:PATH
Push-Location -LiteralPath $projectRoot
try {
    $env:APPDATA = $configDirectory
    $env:JAVA_HOME = $JdkPath
    $env:PATH = (Join-Path $JdkPath 'bin') + ';' + $previousPath
    & $flutterCommand @FlutterArguments
    $commandExitCode = $LASTEXITCODE
} finally {
    $env:APPDATA = $previousAppData
    $env:JAVA_HOME = $previousJavaHome
    $env:PATH = $previousPath
    Pop-Location
}
exit $commandExitCode
