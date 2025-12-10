<#
.SYNOPSIS
  Automatiza `git push` y `terraform apply` para este proyecto.

.DESCRIPTION
  - Comprueba el remote `origin` para obtener la URL del repo (si no se pasa `-RepoUrl`).
  - Añade, commitea y hace push de los cambios en la rama actual.
  - Entra en `terraform/`, ejecuta `terraform init` y `terraform apply -auto-approve` pasando `repo_url`.
  - Muestra la salida `alb_dns_name` al finalizar.

USAGE
  .\deploy.ps1 -CommitMessage "mensaje" [-RepoUrl "https://..."]

REQUIREMENTS
  - PowerShell (Windows)
  - Git in PATH
  - Terraform v1.x and AWS credentials configured in environment (AWS CLI/ENV vars)
#>

param(
    [string]$CommitMessage = "deploy: update",
    [string]$RepoUrl = "",
    [switch]$SkipCommit
)

function ExitOnError($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

# Ensure git exists
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    ExitOnError "Git no está instalado o no está en PATH."
}

# Determine repo root (assume script run from repo root or any subfolder)
$RepoRoot = (Resolve-Path -Path ".").Path

# Get origin URL if RepoUrl not provided
if (-not $RepoUrl) {
    try {
        $origin = git -C $RepoRoot config --get remote.origin.url 2>$null
    } catch {
        $origin = $null
    }
    if ($origin) {
        $RepoUrl = $origin.Trim()
        Write-Host "Detected origin URL: $RepoUrl"
    } else {
        $RepoUrl = Read-Host "No se encontró remote.origin. Introduce la URL pública del repo (https://...)"
    }
}

if (-not $RepoUrl) { ExitOnError "Repo URL vacía." }

if (-not $SkipCommit) {
    # Show git status
    $status = git -C $RepoRoot status --porcelain
    if ($status) {
        Write-Host "Cambios detectados. Haciendo commit con mensaje: $CommitMessage"
        git -C $RepoRoot add . || ExitOnError "git add falló"
        git -C $RepoRoot commit -m "$CommitMessage" || Write-Host "No hay cambios que commitear o commit falló (continuando)"
    } else {
        Write-Host "No hay cambios a commitear."
    }

    # Push current branch
    $branch = git -C $RepoRoot rev-parse --abbrev-ref HEAD
    Write-Host "Haciendo push de la rama $branch a origin"
    git -C $RepoRoot push origin $branch || ExitOnError "git push falló"
}

# Terraform apply
$TerraformDir = Join-Path $RepoRoot 'terraform'
if (-not (Test-Path $TerraformDir)) { ExitOnError "No se encontró la carpeta 'terraform' en el repo root." }

Push-Location $TerraformDir
try {
    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        ExitOnError "Terraform no está instalado o no está en PATH."
    }

    Write-Host "Inicializando Terraform..."
    terraform init -input=false || ExitOnError "terraform init falló"

    Write-Host "Aplicando Terraform (pasando repo_url=$RepoUrl)..."
    terraform apply -auto-approve -var "repo_url=$RepoUrl" || ExitOnError "terraform apply falló"

    Write-Host "Obteniendo output 'alb_dns_name'..."
    $alb = terraform output -raw alb_dns_name 2>$null
    if ($alb) {
        Write-Host "ALB DNS: $alb" -ForegroundColor Green
    } else {
        Write-Host "No se pudo obtener 'alb_dns_name' (revisa terraform outputs)." -ForegroundColor Yellow
        terraform output || Write-Host "No hay outputs."
    }
}
finally {
    Pop-Location
}

Write-Host "deploy.ps1 finalizado." -ForegroundColor Cyan
