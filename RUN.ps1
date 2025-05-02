[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$BaseUrl,
    [Parameter(Mandatory = $true)]
    [string]$TenantId,
    [Parameter(Mandatory = $true)]
    [string]$ClientId,
    [Parameter(Mandatory = $true)]
    [string]$ClientSecret,
    [string]$OutputPath = "edmx.xml"
)

$OutputDir = Split-Path -Path $OutputPath -Parent
if ($OutputDir -and -not (Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$TokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
$MetadataUrl = "$BaseUrl/`$metadata?`$schemaversion=2.0"

function Get-AccessToken {
    $Body = @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = "https://api.businesscentral.dynamics.com/.default"
    }
    try {
        $Response = Invoke-RestMethod -Method Post -Uri $TokenUrl -Body $Body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
        return $Response.access_token
    }
    catch {
        Write-Error "Failed to get access token: $($_.Exception.Message)"
        exit 1
    }
}

function Fetch-AndSaveEdmx {
    param ([string]$Token)
    $Headers = @{
        Authorization = "Bearer $Token"
        Accept        = "application/xml"
    }
    try {
        $Response = Invoke-WebRequest -Method Get -Uri $MetadataUrl -Headers $Headers -ErrorAction Stop
        $Content = $Response.Content
        if (-not $Content.Trim().StartsWith('<')) {
            Write-Error "Expected XML, got: $($Content.Substring(0, [Math]::Min(100, $Content.Length)))..."
            exit 1
        }
        Set-Content -Path $OutputPath -Value $Content -Encoding UTF8
        Write-Host "EDMX saved to $OutputPath"
    }
    catch {
        Write-Error "Failed to fetch/save EDMX: $($_.Exception.Message)"
        exit 1
    }
}

try {
    $AccessToken = Get-AccessToken
    Fetch-AndSaveEdmx -Token $AccessToken
    $ExePath = Join-Path -Path $PSScriptRoot -ChildPath "EdmxToYaml.exe"
    if (-not (Test-Path -Path $ExePath)) {
        Write-Error "EdmxToYaml.exe not found in current directory"
        exit 1
    }
    & $ExePath $OutputPath
    Write-Host "EdmxToYaml.exe executed with $OutputPath"
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}