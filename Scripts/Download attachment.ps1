# Define your ServiceNow instance URL
$baseUrl = "https://redbox.service-now.com"
 
# ServiceNow credentials
$username = "gnaneswarreddy.thota@ust.com"
$password = "Gnaneswar@27111996"
 
# Create a credential object for basic authentication
$credential = New-Object System.Management.Automation.PSCredential($username, ($password | ConvertTo-SecureString -AsPlainText -Force))
 
# Define the REST API endpoint to get files from the sys_attachment table
$filesEndpoint = "$baseUrl/api/now/attachment?sysparm_query=table_nameSTARTSWITHalm_hardware%5Esize_bytes!%3D44%5EORsize_bytes%3DNULL&sysparm_limit=10000&sysparm_offset=10000"
 
# Define the output directory to save downloaded files
$outputDirectory = "C:\Downloads\ServiceNow"
 
# Function to make a REST API call
function Invoke-ServiceNowApi {
    param (
        [string]$Endpoint,
        [System.Management.Automation.PSCredential]$Credential
    )
    try {
        $response = Invoke-RestMethod -Uri $Endpoint -Credential $Credential -Method Get -ContentType "application/json"
        return $response
    } catch {
        Write-Error "Error occurred while invoking ServiceNow API: $_"
    }
}
 
# Function to download files
function Download-Files {
    param (
        [string]$Endpoint,
        [System.Management.Automation.PSCredential]$Credential,
        [string]$OutputDirectory
    )
 
    $response = Invoke-ServiceNowApi -Endpoint $Endpoint -Credential $Credential
 
    if ($response.result) {
        foreach ($file in $response.result) {
            $fileUrl = $file.download_link
            $fileName = $file.sys_id + "__" +$file.file_name
            $filePath = Join-Path -Path $OutputDirectory -ChildPath $fileName
 
            try {
                Invoke-WebRequest -Uri $fileUrl -Credential $Credential -OutFile $filePath
                Write-Host "Downloaded file: $fileName" -ForegroundColor Green
            } catch {
                Write-Error "Error downloading file ${fileName}: $_"
            }
        }
    } else {
        Write-Host "No files found."
    }
}
 
# Main script
 
# Create output directory if it doesn't exist
if (-not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}
 
# Download files from sys_attachment table
Write-Host "Downloading files from sys_attachment table..." -ForegroundColor Yellow
Download-Files -Endpoint $filesEndpoint -Credential $credential -OutputDirectory $outputDirectory