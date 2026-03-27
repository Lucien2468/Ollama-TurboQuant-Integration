# Ollama: Turbo Edition - Setup Script
# Automates the building of the Ollama-Turbo Docker image and ensures Docker is ready.

Write-Host "🚀 Starting Ollama Turbo Setup..." -ForegroundColor Green

# Check if Docker is installed
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed! Please install Docker Desktop and try again."
    exit 1
}

# Check if Docker is running
docker info > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker is not running! Start Docker Desktop and try again."
    exit 1
}

Write-Host "📦 Building the 'ollama-turbo' image from source..." -ForegroundColor Cyan
# Rebuild the image from Dockerfile.turbo in the ollama directory
docker build -f ollama/Dockerfile.turbo -t ollama-turbo .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Turbo Image built successfully!" -ForegroundColor Green
    Write-Host "💡 You can now use '.\turbo-ollama.ps1' to run commands like natively." -ForegroundColor Cyan
} else {
    Write-Error "❌ Build failed. Check the output above for errors."
    exit 1
}
