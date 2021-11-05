using namespace Microsoft.IdentityModel.Clients.ActiveDirectory
Add-Type -Path .\Microsoft.IdentityModel.Clients.ActiveDirectory.dll

$TenantId = ''
$ClientId = ''
$ClientSecret = ''
$Resource = 'https://<org>.crm.dynamics.com'
$TenantUrl = "https://login.microsoftonline.com/$TenantId"

$Context = [AuthenticationContext]::new($TenantUrl)
$ClientCredential = [ClientCredential]::new($ClientId, $ClientSecret)
$Result = $Context.AcquireTokenAsync($Resource, $ClientCredential).Result
$Result.AccessToken

$REST = @{
    Uri     = 'https://<org>.api.crm.dynamics.com/api/data/v9.2/accounts?$select=name'
    Method  = 'Get'
    Headers = @{ Authorization = "Bearer $($Result.AccessToken)" }
}
(Invoke-RestMethod @REST).value | Format-Table

$Api = [Uri]::new('https://<org>.api.crm.dynamics.com/api/data/v9.2/')
$Headers = @{
    #CallerObjectId = ""
    Authorization = "Bearer $($Result.AccessToken)" 
}

(Invoke-RestMethod -Headers $Headers -Method Get -Uri ([Uri]::new($Api, 'accounts'))).value | Format-Table
(Invoke-RestMethod -Headers $Headers -Method Get -Uri ([Uri]::new($Api, 'contacts'))).value | Format-Table
(Invoke-RestMethod -Headers $Headers -Method Get -Uri ([Uri]::new($Api, 'accounts?$select=name'))).value | Format-Table

$account = @{
    name = "Sample Account"
    description="This is Sample account created from PowerShell"
    revenue = 500000
}

$update = @{
    name = "Updated Sample Account"
    description="This is Sample account updated from PowerShell"
    revenue = 1500000
}

Invoke-RestMethod -ContentType 'application/json' -Headers $Headers -Method Post -Uri ([Uri]::new($Api, 'accounts')) -Body ($account | ConvertTo-Json)
Invoke-RestMethod -ContentType 'application/json' -Headers $Headers -Method Patch -Uri ([Uri]::new($Api, 'accounts(81aa8df1-5d3e-ec11-8c63-0022480a3b03)')) -Body ($update | ConvertTo-Json)

Invoke-RestMethod -Headers $Headers -Method Get -Uri ([Uri]::new($Api, 'accounts(81aa8df1-5d3e-ec11-8c63-0022480a3b03)'))
