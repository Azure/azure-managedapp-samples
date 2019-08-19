$resourceDefinitions = Get-AzureRmResource | Where-Object {$_.ResourceType -eq "Microsoft.Solutions/applicationDefinitions"}

foreach ($resourceDefinition in $resourceDefinitions)
{
  $applicationDefinition = Get-AzureRmManagedApplicationDefinition -ResourceGroupName $resourceDefinition.ResourceGroupName
  
  #Get properties
  $applicationTemplate = $applicationDefinition.Properties.Artifacts[0].Uri
  $mainTemplate = $applicationTemplate -replace "applicationResourceTemplate.json", "mainTemplate.json"
  echo $resourceDefinition.ResourceGroupName; $mainTemplate
 }