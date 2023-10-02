param (
    [string]$filePath
)

# Check if filePath parameter is provided
if (-Not $filePath) {
    Write-Host "Usage: .\check_file_type.ps1 -filePath [Path to file]"
    exit 1
}

# Read the first 10 bytes from the file to check for magic numbers
$bytes = Get-Content -Encoding Byte -ReadCount 10 -TotalCount 10 -Path $filePath

# Identify file type based on magic numbers or file headers
switch -regex ($bytes -join ' ') {
    "37 80 68 70"                  { Write-Host "PDF document" }
    "80 75 3 4"                    { Write-Host "ZIP archive" }
    "137 80 78 71 13 10 26 10"     { Write-Host "PNG image" }
    "255 216 255"                  { Write-Host "JPEG image" }
    "66 77"                        { Write-Host "BMP image" }
    "71 73 70 56"                  { Write-Host "GIF image" }
    "73 73 42 0"                   { Write-Host "TIF image" }
    "77 90"                        { Write-Host "Windows executable" }
    "35 33 21"                     { Write-Host "Unix script" }
    "255 254 0 0"                  { Write-Host "UTF-32 LE" }
    "0 0 254 255"                  { Write-Host "UTF-32 BE" }
    "255 254"                      { Write-Host "UTF-16 LE" }
    "254 255"                      { Write-Host "UTF-16 BE" }
    "239 187 191"                  { Write-Host "UTF-8" }
    "43 47 118"                    { Write-Host "UTF-7" }
    "247 100 76"                   { Write-Host "UTF-1" }
    "221 115 102"                  { Write-Host "UTF-EBCDIC" }
    "157 166 167"                  { Write-Host "SCSU" }
    "14 15 76"                     { Write-Host "BOCU-1" }
    "251 238 236"                  { Write-Host "GB-18030" }
    default {
        $isText = $true
        $moreBytes = Get-Content -Encoding Byte -ReadCount 100 -TotalCount 100 -Path $filePath
        foreach ($b in $moreBytes) {
            if ($b -lt 32 -or $b -gt 126) {
                $isText = $false
                break
            }
        }
        if ($isText) {
            Write-Host "Text file (ASCII or UTF-8)"
        } else {
             $asciiOutput = [System.Text.Encoding]::ASCII.GetString($bytes)
             $moreBytesasciiOutput = [System.Text.Encoding]::ASCII.GetString($moreBytes)
             Write-Host "`n`nIt's either Unknown, binary, or ASCII.`n`nAre these 10 bytes ASCII:`n$asciiOutput`n`n`nor these 100 bytes:`n$moreBytesasciiOutput`n`n`n`n"
        }
    }
}
