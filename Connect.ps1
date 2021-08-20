using namespace Microsoft.IdentityModel.Clients.ActiveDirectory
Add-Type -Path .\Microsoft.IdentityModel.Clients.ActiveDirectory.dll
# https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory/

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
