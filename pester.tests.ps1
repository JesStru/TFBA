BeforeDiscovery {
    $plan = terraform show -json .\terraform.plan | ConvertFrom-Json
    $variables = $plan.variables | Get-Member -Type Properties | Select-Object -ExpandProperty Name
}
Describe "Test-Case" {
    It "Resource <_.name> has a valid name" -ForEach $plan.resource_changes {
        $_.name | Should -Be ($_.type + "-01")
    }

    It "Resource <_.name> has valid tags" -ForEach $plan.resource_changes {
        $_.tags | Should -Not -BeNullOrEmpty
    }

    It "Variable <_> is valid" -ForEach $variables {
        $_ | Should -BeIn $plan.resource_changes.type
    }
}

checkov --file .\tf.json --external-checks-dir .\policies\

