# .NET 3.1 and .NET 5 SDK must be installed
# PowerShell v7.1.4 minimum must be installed
# https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory/

using namespace Microsoft.IdentityModel.Clients.ActiveDirectory
Add-Type -Path .\Microsoft.IdentityModel.Clients.ActiveDirectory.dll


$TenantId = ''
$ClientId = ''
$ClientSecret = ''
$Resource = 'https://<Organization>.crm.dynamics.com'
$TenantUrl = "https://login.microsoftonline.com/$TenantId"

$Context = [AuthenticationContext]::new($TenantUrl)
$ClientCredential = [ClientCredential]::new($ClientId, $ClientSecret)
$Result = $Context.AcquireTokenAsync($Resource, $ClientCredential).Result
$Result.AccessToken

$REST = @{
    Uri = 'https://<Organization>.api.crm.dynamics.com/api/data/v9.2/accounts?$select=name'
    Method = 'Get'
    ContentType = 'application/json'
    Headers = @{
        ContentType = 'application/json'
        Authorization = "Bearer $($Result.AccessToken)"
    }
}
(Invoke-RestMethod @REST).value | Format-Table

Invoke-RestMethod -Method Delete -Uri "https://jsonplaceholder.typicode.com/posts/1"
