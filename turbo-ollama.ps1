# TurboQuant: Ollama Turbo Edition Wrapper
# Provides a drop-in 'ollama' command experience via the modified Docker container.

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    $RemainingArgs
)

$ContainerName = "ollama-turbo"
$ImageName     = "ollama-turbo"

# Check if Docker is running
docker info > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker is not running. Start Docker Desktop and try again."
    exit $LASTEXITCODE
}

# Ensure the container is running and healthy
$IsRunning = docker inspect -f '{{.State.Running}}' $ContainerName 2>$null
if ($LASTEXITCODE -ne 0) {
    # Container doesn't exist, create it
    Write-Host "Creating and starting Ollama Turbo container..." -ForegroundColor Cyan
    # Map models to /models so they are persistent on the host
    docker run -d -p 11434:11434 --name $ContainerName -v "d:\turboquant:/models" -e OLLAMA_MODELS="/models" $ImageName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to start container. Make sure native Ollama or another app isn't already using port 11434."
        exit $LASTEXITCODE
    }
    # Wait for the server to start
    Start-Sleep -Seconds 3
} elseif ($IsRunning -ne "true") {
    # Container exists but is stopped, start it
    Write-Host "Starting existing Ollama Turbo container ($ContainerName)..." -ForegroundColor Cyan
    docker start $ContainerName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to start existing container. Make sure native Ollama or another app isn't already using port 11434."
        exit $LASTEXITCODE
    }
    Start-Sleep -Seconds 3
}

# Forward the command to the container, running from the /models directory
if ($RemainingArgs.Count -eq 0) {
    docker exec -it -w /models $ContainerName ollama
} else {
    docker exec -it -w /models $ContainerName ollama @RemainingArgs
}
