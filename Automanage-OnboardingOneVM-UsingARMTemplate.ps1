<#
.SYNOPSIS 
    Onboard a azure virtual machine to azure automanage

.DESCRIPTION
   This script will execute the below operations to onboard a azure virtual machine to azure automanage
      1. Get the subscription and derives the automanage account name.
      2. Initialize the TemplateParameterObject for template Automanage-OnboardingOneVM.template.json.
      3. Invokes New-AzDeployment for template Automanage-OnboardingOneVM.template.json.

   Template Automanage-OnboardingOneVM.template.json details:
      1. Creates automanage account.
      2. Grants RBAC role Contributor and Resource Policy Contributor.
      3. Creates Assignment for the VM.
       
.EXAMPLE 
   .\Automanage-OnboardingOneVM-UsingARMTemplate.ps1 -SubscriptionId <SubscriptionId> -VMResourceGroup <VMResourceGroup> -VMName <VMName>

.NOTES
    AUTHOR: Azure automanage Team
    LASTEDIT: Nov 09, 2020  

#>

Param (
    [Parameter(Mandatory = $true)]
    [String] $SubscriptionId,

    [Parameter(Mandatory = $true)]
    [String] $VMResourceGroup,

    [Parameter(Mandatory = $true)]
    [String] $VMName
)

# Install Az module if the Az module is not found
#Install-Module -Name Az -Force -AllowClobber
#Get-Module -Name Az.* -ListAvailable

# Connect 
#Connect-AzAccount

$Subscription = Select-AzSubscription -SubscriptionId $SubscriptionId

# Parameter
$AutoManageAccountSubscriptionId = $SubscriptionId
$AutoManageAccountName = $Subscription.Subscription.Name + "-ABP-AT"
$AutoManageAccountResourceGroup = $AutoManageAccountName + "_group"
$AutoManageAccountLocation = "eastus" #Automanage account location hardcoded to eastus

$ARMTemplateparams = @{
    autoManageAccountSubscriptionId = $AutoManageAccountSubscriptionId
    autoManageAccountResourceGroup = $AutoManageAccountResourceGroup
    autoManageAccountName = $AutoManageAccountName
    autoManageAccountLocation = $AutoManageAccountLocation
    vmResourceGroup = $VMResourceGroup
    vmName = $VMName
}

New-AzDeployment -Location $AutoManageAccountLocation -Name $AutoManageAccountName `
    -TemplateUri https://raw.githubusercontent.com/ikanni/AutoManage-ARMTemplates/main/Automanage-OnboardingOneVM.template.json `
    -TemplateParameterObject $ARMTemplateparams 
