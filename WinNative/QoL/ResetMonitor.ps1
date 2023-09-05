$gpus = Get-PnpDevice | Where-Object {$_.Class -eq 'Display'}; $gpus | Disable-PnpDevice -Confirm:$false; Start-Sleep -Seconds 10; $gpus | Enable-PnpDevice -Confirm:$false
