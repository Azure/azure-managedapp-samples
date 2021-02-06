[cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $SubscriptionId,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Location = 'westcentralus',

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $ResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Name,

    [Parameter()]
    [string] $DisplayName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Description,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $PrincipalId,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $RoleDefinitionId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635',

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $StorageAccountName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $StorageContainerName,

    [Parameter()]
    [ValidateSet('None','ReadOnly')]
    [string] $LockLevel = 'ReadOnly'
)

Function Write-Verbose
{
  Param(
    [Parameter(Position=1)]
    [string]$Message
  )

  Microsoft.PowerShell.Utility\Write-Verbose ("{0} - {1}" -f (Get-Date).ToString("HH:mm:ss"),$Message)
}

if($DisplayName -eq "")
{
  $DisplayName = $Name
}

$Error.Clear()

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if($here -eq $null) {$here="."}

$TemplateParameters = @{
  "managedAppName" = $Name;
  "lockLevel" = $LockLevel;
  "authorizations" = @(
    @{
      "principalId" = $PrincipalId;
      "roleDefinitionId" = $RoleDefinitionId
    }
  );
  "description" = $Description;
  "displayName" = $DisplayName;
  "packageFileUri" = "https://$StorageAccountName.blob.core.windows.net/$StorageContainerName/$Name.zip"
}

ForEach($managedAppFile In @("createUiDefinition.json","mainTemplate.json"))
{
  Write-Verbose "Verifying if $managedAppFile exists"
  if(Test-Path "$here\$managedAppFile")
  {
    Write-Verbose "$managedAppFile exists. Checking proper cases in the file name"
    if((Get-ChildItem "$here\$managedAppFile" | Select-Object -ExpandProperty Name) -cne $managedAppFile)
    {
      Write-Error "$managedAppFile exists but its name doesn't match the expected cases. Please verify and try again"
      Exit(-1)
    }
  }
  else
  {
    Write-Error "$managedAppFile doesn't exists"
    Exit(-1)
  }
}

Write-Verbose "Verifying output folder"
if(Test-Path "$here\output")
{
  Write-Verbose "Cleaning Up output folder"
  Get-ChildItem "$here\output" | Remove-Item -force | Out-Null
}
else
{
  Write-Verbose "Creating output folder"
  New-Item -Path "$here\output" -ItemType Directory | Out-Null
}

Write-Verbose "Verify if managedAppTemplate.json exists"
if(!(Test-Path "$here\managedAppTemplate.json"))
{
  Write-Error "$managedAppTemplate not found in the current script location"
  Exit(-1)
}

Get-ChildItem "$here\*" -Include mainTemplate.json, createUiDefinition.json | Compress-Archive -DestinationPath "$here\output\$Name.zip"

Write-Verbose "Logging in..."
$context = $null
try {
  $context = Get-AzureRmContext
}
catch {
  
}

if($context.Subscription.Id -eq $null)
{
  Login-AzureRmAccount | Out-Null

  if($context.Subscription.Id -eq $null)
  {
    Write-Warning "Action cancelled"
    Exit(-1)
  }
}

Write-Verbose "Logged into Azure"

Write-Verbose "Selecting subscription $subscriptionId"
Select-AzureRmSubscription -SubscriptionId $subscriptionId | Out-Null

Write-Verbose "Verifying if managedApp provider is registered"
If(!(Get-AzureRmResourceProvider -ProviderNamespace "Microsoft.Solutions" -ErrorAction SilentlyContinue))
{
  Write-Verbose "Registering Resource Provider"
  Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.Solutions" | Out-Null
}

Write-Verbose "Verifying if $ResourceGroupName exists in $Location"
If(!(Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue))
{
  Write-Verbose "$ResourceGroupName not found, proceeding to create it"
  New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Force | Out-Null
}
else {
  Write-Verbose "Using existing resource group $ResourceGroupName at $Location"
}

Write-Verbose "Verifying if Storage Account ($StorageAccountName) exists"
If(!(Get-AzureRmStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue))
{
    Write-Verbose "$StorageAccountName not found, proceeding to create it"
    try {
      New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName 'Standard_LRS' -ErrorAction Stop | Out-Null
    }
    catch {
      Write-Error "Error while attempting to create $StorageAccountName storage account"
      Write-Error $error[0].Exception
      Exit(-2)
    }
}
else {
  Write-Verbose "Using existing storage account $StorageAccountName at $Location"
}

Write-Verbose "Obtain the Storage Account authentication keys using Azure Resource Manager (ARM)"
$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName;

Write-Verbose "Use the Azure.Storage module to create a Storage Authentication Context"
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $Keys[0].Value;

If(!(Get-AzureStorageContainer -Context $StorageContext -Name $StorageContainerName -ErrorAction SilentlyContinue))
{
  Write-Verbose "Creating blob container ($StorageContainerName) in the Storage Account"
  New-AzureStorageContainer -Context $StorageContext -Name $StorageContainerName -Permission Blob | Out-Null
}
else {
  Write-Verbose "Using existing blob container ($StorageContainerName)"
}

Write-Verbose "Verifying if Managed Application exists in $managedAppResourceGroupName"
$managedApp = Get-AzureRmResource | Where-Object {$_.ResourceType -like "Microsoft.Solutions/applicationDefinitions" -and $_.Name -eq $Name}
if($managedApp)
{
  Write-Warning "$Name exists and it will be removed"
  Remove-AzureRmResource -Force -Verbose -ResourceId $managedApp.ResourceId | Out-Null
}
else
{
  Write-Verbose "$Name not found."
}

Write-Verbose "Uploading ManagedApp Content"
Set-AzureStorageBlobContent -File "$here\output\$Name.zip" -Container $StorageContainerName -Context $StorageContext -Force | Out-Null

Write-Verbose "Publishing Managed App..."
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile "$here\managedAppTemplate.json" -TemplateParameterObject $TemplateParameters