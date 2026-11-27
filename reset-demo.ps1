
# Reset the demo branch to the original vulnerable baseline

Set-Location $PSScriptRoot

$Baseline = "demo-baseline"
$Demo = "main"
$Remote = "origin"

# Check for uncommitted or untracked changes
if (git status --porcelain) {
    Write-Host "Please commit or stash your changes first." -ForegroundColor Red
    exit 1
}

# Get latest remote branches
git fetch $Remote
if ($LASTEXITCODE -ne 0) { exit 1 }

# Confirm both branches exist remotely
git show-ref --verify --quiet "refs/remotes/$Remote/$Baseline"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Baseline branch not found." -ForegroundColor Red
    exit 1
}

git show-ref --verify --quiet "refs/remotes/$Remote/$Demo"
if ($LASTEXITCODE -ne 0) {
    Write-Host "main branch not found." -ForegroundColor Red
    exit 1
}

Write-Host "This will discard the main branch's newer commits."
$Confirm = Read-Host "Type RESET to continue"

if ($Confirm -ne "RESET") {
    Write-Host "Cancelled."
    exit
}

# Switch to demo branch
git switch $Demo
if ($LASTEXITCODE -ne 0) { exit 1 }

# Restore original vulnerable code
git reset --hard "$Remote/$Baseline"
if ($LASTEXITCODE -ne 0) { exit 1 }

# Update GitHub
git push --force-with-lease $Remote $Demo
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push failed. Check GitHub branch permissions." -ForegroundColor Red
    exit 1
}

Write-Host "Main successfully restored!" -ForegroundColor Green

#write this: .\reset-demo.ps1
