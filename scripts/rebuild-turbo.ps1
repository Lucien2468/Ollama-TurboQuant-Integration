# Rebuild Ollama Turbo Container
# Ensures host-side CUDA changes are compiled into the binary.

$ImageName = "ollama-turbo"
$ContainerName = "ollama-turbo"

Write-Host "`n🔨 Rebuilding Ollama Turbo Edition..." -ForegroundColor Cyan

# 1. Build the new image
Write-Host "  > Running Docker build (this may take several minutes)..." -ForegroundColor Gray
docker build -f ollama/Dockerfile.turbo -t $ImageName ollama/
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker build failed. Check your CUDA/C++ syntax."
    exit $LASTEXITCODE
}

# 2. Stop and remove the old container
if (docker ps -a --format '{{.Names}}' | Select-String -Quiet "^$ContainerName$") {
    Write-Host "  > Removing old container..." -ForegroundColor Gray
    docker stop $ContainerName | Out-Null
    docker rm $ContainerName | Out-Null
}

# 3. Start the new container
Write-Host "  > Starting fresh container..." -ForegroundColor Gray
docker run -d -p 11434:11434 --name $ContainerName --gpus all -v "d:\turboquant:/root/.ollama/models" $ImageName
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to start new container."
    exit $LASTEXITCODE
}

Write-Host "`n✅ Rebuild complete! Run .\perf-tests\bench-inference.ps1 to verify.`n" -ForegroundColor Green
