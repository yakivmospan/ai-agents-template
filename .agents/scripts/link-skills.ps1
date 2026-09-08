# Windows equivalent of link-skills.sh. Requires Developer Mode (or an elevated shell)
# for New-Item -ItemType SymbolicLink; falls back to forwarding stubs otherwise.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$src  = Join-Path $root ".agents\skills"
$dest = Join-Path $root ".claude\skills"

if (-not (Test-Path $src)) { throw "$src not found - run from inside the repo" }
New-Item -ItemType Directory -Force -Path $dest | Out-Null

# Prune first: a leftover .claude\skills entry with no matching .agents\skills source means that
# skill was renamed or removed. Left behind, it can still be invoked by name and points at nothing.
if (Test-Path $dest) {
    foreach ($existing in Get-ChildItem -Path $dest -Directory) {
        $srcMatch = Join-Path $src $existing.Name
        if (Test-Path $srcMatch) { continue }
        $item = Get-Item $existing.FullName -Force
        $isStub = Test-Path (Join-Path $existing.FullName ".forwarding-stub")
        if ($item.LinkType -or $isStub) {
            Remove-Item $existing.FullName -Recurse -Force
            Write-Host "prune   $($existing.Name) (no longer in .agents/skills/)"
        }
    }
}

foreach ($skill in Get-ChildItem -Path $src -Directory) {
    $target = Join-Path $dest $skill.Name
    if ((Test-Path $target) -and -not (Test-Path (Join-Path $target ".forwarding-stub"))) {
        $item = Get-Item $target -Force
        if (-not $item.LinkType) { Write-Host "skip    $($skill.Name) (real dir exists)"; continue }
    }
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }

    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $skill.FullName -Force | Out-Null
        Write-Host "link    $($skill.Name)"
    } catch {
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        New-Item -ItemType File -Force -Path (Join-Path $target ".forwarding-stub") | Out-Null
        $lines = Get-Content (Join-Path $skill.FullName "SKILL.md")
        $out = @(); $fences = 0
        foreach ($line in $lines) {
            $out += $line
            if ($line -eq "---") { $fences++; if ($fences -ge 2) { break } }
        }
        $out += ""
        $out += "> Forwarding stub. The real skill lives at ``.agents/skills/$($skill.Name)/SKILL.md``."
        $out += "> Read that file now and follow it. Scripts it references are relative to that directory."
        $out | Set-Content (Join-Path $target "SKILL.md")
        Write-Host "stub    $($skill.Name) (symlinks unavailable - enable Developer Mode for real links)"
    }
}
