# Windows equivalent of link-skills.sh — the same passes; its messages may be worded differently. Symbolic links need Developer
# Mode (or an elevated shell); without them it falls back to forwarding stubs.

param([string]$RepoRoot)

$ErrorActionPreference = "Stop"
$root  = if ($RepoRoot) { (Resolve-Path $RepoRoot).Path } else { Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) }
$src   = Join-Path $root ".agents\skills"
$local = Join-Path $root ".agents\.local\skills"
$dest  = Join-Path $root ".claude\skills"
$counts = @{ linked = 0; stubbed = 0; skipped = 0; pruned = 0 }

if (-not (Test-Path $src)) { throw "$src not found - run from inside the repo" }
New-Item -ItemType Directory -Force -Path $dest | Out-Null

# A link or a stub this script wrote - as opposed to a real skill folder someone put there.
function Test-Ours($path) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    return ([bool]$item.LinkType) -or (Test-Path (Join-Path $path ".forwarding-stub"))
}

# $true for a real link, $false when a stub had to be written instead. The target is relative to the
# link's own folder, as link-skills.sh writes it, so links survive the repository moving.
function Set-LinkOrStub($linkPath, $sourceDir, $sourceRel, $targetRel) {
    if (Test-Path -LiteralPath $linkPath) { Remove-LinkOrStub $linkPath }
    try {
        Push-Location (Split-Path -Parent $linkPath)
        try {
            New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetRel -Force | Out-Null
            if (-not (Test-Path (Join-Path $linkPath "SKILL.md"))) { throw "link does not resolve" }
        }
        finally { Pop-Location }
        return $true
    } catch {
        Remove-Item -LiteralPath $linkPath -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Force -Path $linkPath | Out-Null
        New-Item -ItemType File -Force -Path (Join-Path $linkPath ".forwarding-stub") | Out-Null
        $out = @(); $fences = 0
        foreach ($line in Get-Content (Join-Path $sourceDir "SKILL.md")) {
            $out += $line
            if ($line -eq "---") { $fences++; if ($fences -ge 2) { break } }
        }
        $out += ""
        $out += "> Forwarding stub. The real skill lives at ``$sourceRel/SKILL.md``."
        $out += "> Read that file now and follow it; ignore nothing in it. Any scripts it references are"
        $out += "> relative to ``$sourceRel/``, not to this directory."
        $out | Set-Content (Join-Path $linkPath "SKILL.md")
        return $false
    }
}

# The exclude file git reads for this checkout - a worktree's .git is a file, so ask git.
function Get-ExcludeFile {
    $file = git -C $root rev-parse --git-path info/exclude 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $file) { return $null }
    if (-not [System.IO.Path]::IsPathRooted($file)) { $file = Join-Path $root $file }
    return $file
}

function Add-Exclude($line) {
    $file = Get-ExcludeFile
    if (-not $file) { return }
    if ((Test-Path $file) -and ((Get-Content $file) -contains $line)) { return }
    try { Add-Content -Path $file -Value $line -ErrorAction Stop }
    catch { Write-Warning "add $line to $file by hand, so it never reaches a commit" }
}

# A link is removed as a link: -Recurse through one can delete the real skill folder it points at.
function Remove-LinkOrStub($path) {
    $item = Get-Item -LiteralPath $path -Force
    if ($item.LinkType) { $item.Delete() } else { Remove-Item -LiteralPath $path -Recurse -Force }
}

function Remove-Exclude($line) {
    $file = Get-ExcludeFile
    if (-not $file) { return }
    if (-not (Test-Path $file)) { return }
    $lines = @(Get-Content $file)
    if ($lines -notcontains $line) { return }
    $lines | Where-Object { $_ -ne $line } | Set-Content $file
}

function Remove-Orphans($dir, $sourceRoot) {
    foreach ($existing in Get-ChildItem -Path $dir -Force -ErrorAction SilentlyContinue) {
        if (-not (Test-Ours $existing.FullName)) { continue }
        if (Test-Path (Join-Path $sourceRoot $existing.Name)) { continue }
        Remove-LinkOrStub $existing.FullName
        Write-Host "prune   $($existing.Name) (its source is gone)"
        $counts.pruned++
    }
}

# Local skills first, so the main pass links them into .claude\skills like any other.
if (Test-Path $local) {
    foreach ($skill in Get-ChildItem -Path $local -Directory) {
        if (-not (Test-Path (Join-Path $skill.FullName "SKILL.md"))) { continue }
        $target = Join-Path $src $skill.Name
        if ((Test-Path $target) -and -not (Test-Ours $target)) {
            Write-Host "skip    $($skill.Name) (a shared .agents/skills/$($skill.Name) exists - the local one is not linked)"
            $counts.skipped++
            continue
        }
        [void](Set-LinkOrStub $target $skill.FullName ".agents/.local/skills/$($skill.Name)" "..\.local\skills\$($skill.Name)")
        Add-Exclude "/.agents/skills/$($skill.Name)"
        Add-Exclude "/.claude/skills/$($skill.Name)"
    }
}

Remove-Orphans $src $local
Remove-Orphans $dest $src

# A skill that is shared now - a real folder, not a link - must not stay hidden from git by the
# exclude lines it had while it was local.
foreach ($skill in Get-ChildItem -Path $src -Directory) {
    if (Test-Ours $skill.FullName) { continue }
    Remove-Exclude "/.agents/skills/$($skill.Name)"
    Remove-Exclude "/.claude/skills/$($skill.Name)"
}

foreach ($skill in Get-ChildItem -Path $src -Directory) {
    $target = Join-Path $dest $skill.Name
    if ((Test-Path $target) -and -not (Test-Ours $target)) {
        Write-Host "skip    $($skill.Name) (a real .claude/skills/$($skill.Name) already exists)"
        $counts.skipped++
        continue
    }
    if (Set-LinkOrStub $target $skill.FullName ".agents/skills/$($skill.Name)" "..\..\.agents\skills\$($skill.Name)") {
        Write-Host "link    $($skill.Name)"
        $counts.linked++
    } else {
        Write-Host "stub    $($skill.Name) (symlinks unavailable - enable Developer Mode for real links)"
        $counts.stubbed++
    }
}

Write-Host ""
Write-Host "linked: $($counts.linked)  stubbed: $($counts.stubbed)  skipped: $($counts.skipped)  pruned: $($counts.pruned)"
