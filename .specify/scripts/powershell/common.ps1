#!/usr/bin/env pwsh
# Common PowerShell functions analogous to common.sh

function Get-RepoRoot {
    $scriptRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "../../..")).Path
    if (Test-Path -LiteralPath (Join-Path $scriptRoot '.specify') -PathType Container) {
        return $scriptRoot
    }

    try {
        $result = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    # Fall back to script location for non-git repos
    return (Resolve-Path (Join-Path $PSScriptRoot "../../..")).Path
}

function Get-CurrentBranch {
    # First check if SPECIFY_FEATURE environment variable is set
    if ($env:SPECIFY_FEATURE) {
        return $env:SPECIFY_FEATURE
    }
    
    # Then check git if available
    try {
        $result = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    # For non-git repos, try to find the latest feature directory
    $repoRoot = Get-RepoRoot
    $specsDir = Join-Path $repoRoot "specs"
    
    if (Test-Path $specsDir) {
        $latestFeature = ""
        $highest = 0
        
        Get-ChildItem -Path $specsDir -Directory | ForEach-Object {
            if ($_.Name -match '^(\d{3})-') {
                $num = [int]$matches[1]
                if ($num -gt $highest) {
                    $highest = $num
                    $latestFeature = $_.Name
                }
            }
        }
        
        if ($latestFeature) {
            return $latestFeature
        }
    }
    
    # Final fallback
    return "main"
}

function Test-HasGit {
    try {
        git rev-parse --show-toplevel 2>$null | Out-Null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Test-FeatureBranch {
    param(
        [string]$Branch,
        [bool]$HasGit = $true
    )
    
    # For non-git repos, we can't enforce branch naming but still provide output
    if (-not $HasGit) {
        Write-Warning "[specify] Warning: Git repository not detected; skipped branch validation"
        return $true
    }
    
    if ($Branch -notmatch '^[0-9]{3}-') {
        Write-Output "ERROR: Not on a feature branch. Current branch: $Branch"
        Write-Output "Feature branches should be named like: 001-feature-name"
        return $false
    }
    return $true
}

function Get-FeatureDir {
    param([string]$RepoRoot, [string]$Branch)
    Join-Path $RepoRoot "specs/$Branch"
}

function Get-FeaturePathsEnv {
    $repoRoot = Get-RepoRoot
    $currentBranch = Get-CurrentBranch
    $hasGit = Test-HasGit
    $featureDir = Get-FeatureDir -RepoRoot $repoRoot -Branch $currentBranch
    
    [PSCustomObject]@{
        REPO_ROOT     = $repoRoot
        CURRENT_BRANCH = $currentBranch
        HAS_GIT       = $hasGit
        FEATURE_DIR   = $featureDir
        FEATURE_SPEC  = Join-Path $featureDir 'spec.md'
        IMPL_PLAN     = Join-Path $featureDir 'plan.md'
        TASKS         = Join-Path $featureDir 'tasks.md'
        RESEARCH      = Join-Path $featureDir 'research.md'
        DATA_MODEL    = Join-Path $featureDir 'data-model.md'
        QUICKSTART    = Join-Path $featureDir 'quickstart.md'
        CONTRACTS_DIR = Join-Path $featureDir 'contracts'
    }
}

function Test-FileExists {
    param([string]$Path, [string]$Description)
    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Output "  [OK] $Description"
        return $true
    } else {
        Write-Output "  [FAIL] $Description"
        return $false
    }
}

function Get-NormalizedPriority {
    param($Value)

    if ($Value -is [bool]) { return 10 }
    if ($Value -is [string]) {
        $integerText = $Value.Trim()
        if ($integerText -cnotmatch '^[+-]?[0-9]+(?:_[0-9]+)*$') { return 10 }
        $Value = $integerText.Replace('_', '')
    }
    try {
        $priority = [System.Numerics.BigInteger]$Value
    } catch {
        return 10
    }
    return $(if ($priority -ge 1) { $priority } else { 10 })
}

function Get-SortedExtensionIds {
    param([Parameter(Mandatory = $true)][string]$ExtensionsDir)

    $registered = @{}
    $ranked = @()
    $registryFile = Join-Path $ExtensionsDir '.registry'
    if (Test-Path -LiteralPath $registryFile -PathType Leaf) {
        try {
            $registry = [System.IO.File]::ReadAllText($registryFile, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
            if ($registry -isnot [PSCustomObject]) { throw 'Registry root must be an object' }
            $entries = $registry.extensions
            if ($null -ne $entries -and $entries -isnot [PSCustomObject]) { throw 'Registry extensions must be an object' }
            foreach ($entry in $entries.PSObject.Properties) {
                $registered[$entry.Name] = $true
                if ($entry.Name -cnotmatch '^[a-z0-9-]+$' -or $entry.Value -isnot [PSCustomObject]) { continue }
                if ($entry.Value.enabled -eq $false) { continue }
                $ranked += [PSCustomObject]@{
                    Id = $entry.Name
                    Priority = Get-NormalizedPriority -Value $entry.Value.priority
                }
            }
        } catch {
            throw "Invalid extension registry ${registryFile}: $($_.Exception.Message)"
        }
    }

    foreach ($directory in Get-ChildItem -LiteralPath $ExtensionsDir -Directory -ErrorAction SilentlyContinue) {
        if ($directory.Name -cmatch '^[a-z0-9-]+$' -and -not $registered.ContainsKey($directory.Name)) {
            $ranked += [PSCustomObject]@{ Id = $directory.Name; Priority = 10 }
        }
    }
    return $ranked | Sort-Object Priority, Id | ForEach-Object { $_.Id }
}

function Get-Python3Command {
    foreach ($candidate in @('python3', 'python')) {
        if (Get-Command $candidate -ErrorAction SilentlyContinue) {
            $version = & $candidate --version 2>&1
            if ($version -match 'Python 3') { return @($candidate) }
        }
    }
    if (Get-Command py -ErrorAction SilentlyContinue) {
        $version = & py -3 --version 2>&1
        if ($version -match 'Python 3') { return @('py', '-3') }
    }
    return $null
}

function Get-PresetTemplateMetadata {
    param(
        [Parameter(Mandatory = $true)][string]$ManifestPath,
        [Parameter(Mandatory = $true)][string]$TemplateName
    )

    $python = @(Get-Python3Command)
    if (-not $python) { throw 'Python 3 and PyYAML are required to resolve preset template composition' }
    $pythonArgs = if ($python.Count -gt 1) { $python[1..($python.Count - 1)] } else { @() }
    $parser = @'
import json
import sys
import yaml

with open(sys.argv[1], encoding="utf-8") as stream:
    manifest = yaml.safe_load(stream)
if not isinstance(manifest, dict) or not isinstance(manifest.get("provides"), dict):
    raise ValueError("invalid preset manifest structure")
templates = manifest["provides"].get("templates")
if not isinstance(templates, list):
    raise ValueError("preset manifest provides.templates must be a list")
for item in templates:
    if not isinstance(item, dict):
        raise ValueError("preset template entries must be mappings")
    if item.get("name") == sys.argv[2] and item.get("type", "template") == "template":
        strategy = str(item.get("strategy", "replace")).lower()
        if strategy not in ("replace", "prepend", "append", "wrap"):
            raise ValueError("invalid preset template strategy")
        print(json.dumps({"found": True, "strategy": strategy, "file": item.get("file", "")}))
        break
else:
    print(json.dumps({"found": False, "strategy": "replace", "file": ""}))
'@
    $result = & $python[0] @pythonArgs -c $parser $ManifestPath $TemplateName 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Invalid preset manifest ${ManifestPath}: $result" }
    return ($result | ConvertFrom-Json)
}

function Get-TemplateLayers {
    param(
        [Parameter(Mandatory = $true)][string]$TemplateName,
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    if ($TemplateName -cnotmatch '^[a-z0-9-]+$') { return @() }
    $base = Join-Path $RepoRoot '.specify/templates'
    $override = Join-Path $base "overrides/$TemplateName.md"
    if (Test-Path -LiteralPath $override -PathType Leaf) {
        return [PSCustomObject]@{ Path = $override; Strategy = 'replace' }
    }

    $layers = @()
    $baseFound = $false
    $presetsDir = Join-Path $RepoRoot '.specify/presets'
    if (Test-Path -LiteralPath $presetsDir -PathType Container) {
        $presetIds = @()
        $registryFile = Join-Path $presetsDir '.registry'
        if (Test-Path -LiteralPath $registryFile -PathType Leaf) {
            try {
                $registry = [System.IO.File]::ReadAllText($registryFile, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
                if ($registry -isnot [PSCustomObject]) { throw 'Registry root must be an object' }
                if ($registry.presets -and $registry.presets -isnot [PSCustomObject]) { throw 'Registry presets must be an object' }
                $presetIds = @($registry.presets.PSObject.Properties |
                    Where-Object { $_.Name -cmatch '^[a-z0-9-]+$' -and $_.Value -is [PSCustomObject] -and $_.Value.enabled -ne $false } |
                    Sort-Object @{ Expression = { Get-NormalizedPriority -Value $_.Value.priority } }, @{ Expression = { $_.Name } } |
                    ForEach-Object { $_.Name })
            } catch {
                $presetIds = @()
            }
        }
        if (-not $presetIds) {
            $presetIds = @(Get-ChildItem -LiteralPath $presetsDir -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -cmatch '^[a-z0-9-]+$' } | Sort-Object Name | ForEach-Object { $_.Name })
        }

        foreach ($presetId in $presetIds) {
            $presetDir = Join-Path $presetsDir $presetId
            $manifest = Join-Path $presetDir 'preset.yml'
            $strategy = 'replace'
            $candidate = $null
            $manifestDeclaresTemplate = $false
            if (Test-Path -LiteralPath $manifest -PathType Leaf) {
                $metadata = Get-PresetTemplateMetadata -ManifestPath $manifest -TemplateName $TemplateName
                $manifestDeclaresTemplate = [bool]$metadata.found
                if ($metadata.found) {
                    $strategy = [string]$metadata.strategy
                    $relativePath = [string]$metadata.file
                    if ($relativePath -and -not [System.IO.Path]::IsPathRooted($relativePath) -and $relativePath -notmatch '\.\.[\\/]') {
                        $manifestCandidate = Join-Path $presetDir $relativePath
                        if (Test-Path -LiteralPath $manifestCandidate -PathType Leaf) { $candidate = $manifestCandidate }
                    }
                }
            }
            if (-not $candidate -and -not $manifestDeclaresTemplate) {
                foreach ($relativePath in @("templates/$TemplateName.md", "$TemplateName.md")) {
                    $presetCandidate = Join-Path $presetDir $relativePath
                    if (Test-Path -LiteralPath $presetCandidate -PathType Leaf) { $candidate = $presetCandidate; break }
                }
            }
            if ($candidate) {
                $layers += [PSCustomObject]@{ Path = $candidate; Strategy = $strategy }
                if ($strategy -eq 'replace') { $baseFound = $true; break }
            }
        }
    }

    $extensionsDir = Join-Path $RepoRoot '.specify/extensions'
    if (-not $baseFound -and (Test-Path -LiteralPath $extensionsDir -PathType Container)) {
        foreach ($extensionId in Get-SortedExtensionIds -ExtensionsDir $extensionsDir) {
            foreach ($relativePath in @("$extensionId/templates/$TemplateName.md", "$extensionId/$TemplateName.md")) {
                $candidate = Join-Path $extensionsDir $relativePath
                if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                    $layers += [PSCustomObject]@{ Path = $candidate; Strategy = 'replace' }
                    $baseFound = $true
                    break
                }
            }
            if ($baseFound) { break }
        }
    }

    $core = Join-Path $base "$TemplateName.md"
    if (-not $baseFound -and (Test-Path -LiteralPath $core -PathType Leaf)) {
        $layers += [PSCustomObject]@{ Path = $core; Strategy = 'replace' }
    }
    return $layers
}

function Resolve-Template {
    param(
        [Parameter(Mandatory = $true)][string]$TemplateName,
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $layers = @(Get-TemplateLayers -TemplateName $TemplateName -RepoRoot $RepoRoot)
    if ($layers.Count -eq 0) { return $null }
    return $layers[0].Path
}

function Resolve-TemplateContent {
    param(
        [Parameter(Mandatory = $true)][string]$TemplateName,
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $layers = @(Get-TemplateLayers -TemplateName $TemplateName -RepoRoot $RepoRoot)
    if ($layers.Count -eq 0) { return $null }
    if ($layers[0].Strategy -eq 'replace') {
        return [System.IO.File]::ReadAllText($layers[0].Path, [System.Text.Encoding]::UTF8)
    }

    $baseIndex = -1
    for ($index = 0; $index -lt $layers.Count; $index++) {
        if ($layers[$index].Strategy -eq 'replace') { $baseIndex = $index; break }
    }
    if ($baseIndex -lt 0) { throw "Template '$TemplateName' has composing layers but no replace base" }

    $content = [System.IO.File]::ReadAllText($layers[$baseIndex].Path, [System.Text.Encoding]::UTF8)
    for ($index = $baseIndex - 1; $index -ge 0; $index--) {
        $layerContent = [System.IO.File]::ReadAllText($layers[$index].Path, [System.Text.Encoding]::UTF8)
        switch ($layers[$index].Strategy) {
            'prepend' { $content = "$layerContent`n`n$content" }
            'append' { $content = "$content`n`n$layerContent" }
            'wrap' {
                if (-not $layerContent.Contains('{CORE_TEMPLATE}')) { throw 'Wrap strategy missing {CORE_TEMPLATE} placeholder' }
                $content = $layerContent.Replace('{CORE_TEMPLATE}', $content)
            }
            default { throw "Unknown template composition strategy: $($layers[$index].Strategy)" }
        }
    }
    return $content
}

function Test-DirHasFiles {
    param([string]$Path, [string]$Description)
    if ((Test-Path -Path $Path -PathType Container) -and (Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Select-Object -First 1)) {
        Write-Output "  [OK] $Description"
        return $true
    } else {
        Write-Output "  [FAIL] $Description"
        return $false
    }
}

