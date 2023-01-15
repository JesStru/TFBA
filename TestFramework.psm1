Install-Module -Name Pester -Force -SkipPublisherCheck

function Test-ResourceName {
    param (
        [Parameter(Mandatory=$true)]
        $TfPlan
    )
    Describe "Test resource name" {
        $plan = $TfPlan

        foreach($resource in $plan) {
            $name = $resource.name
            $type = $resource.type

            It "Resource $name has a valid name" {
                $name | Should -Be ($type + "_01")
            }
        }
    }
}
Export-ModuleMember -Function Test-ResourceName

function Test-VariableName { 
}
Export-ModuleMember -Function Test-VariableName

function Test-Tags {
}
Export-ModuleMember -Function Test-Tags

Import-Module TestFramework