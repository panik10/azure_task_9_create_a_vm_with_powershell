$location = "uksouth"
$resourceGroupName = "mate-azure-task-9"
$networkSecurityGroupName = "defaultnsg"
$virtualNetworkName = "vnet"
$subnetName = "default"
$vnetAddressPrefix = "10.0.0.0/16"
$subnetAddressPrefix = "10.0.0.0/24"
$publicIpAddressName = "linuxboxpip"
$sshKeyName = "linuxboxsshkey"
$sshKeyPublicKey = Get-Content "/home/er/.ssh/id_ed25519.pub" -Raw
$vmName = "matebox"
$vmImage = "Ubuntu2204"
$vmSize = "Standard_B1s"

Write-Host "Creating a resource group $resourceGroupName ..."
New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Host "Creating a network security group $networkSecurityGroupName ..."
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name SSH  -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow;
$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name HTTP  -Protocol Tcp -Direction Inbound -Priority 1002 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 8080 -Access Allow;
New-AzNetworkSecurityGroup -Name $networkSecurityGroupName -ResourceGroupName $resourceGroupName -Location $location -SecurityRules $nsgRuleSSH, $nsgRuleHTTP

# ↓↓↓ Write your code here ↓↓↓

Write-Host "Creating a virtual network $virtualNetworkName ..."

New-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix $vnetAddressPrefix -SubnetName $subnetName -SubnetPrefix $subnetAddressPrefix

Write-Host "Creating a public IP $publicIpAddressName ..."
$dnsPrefix = "mateazuretask923"
New-AzPublicIpAddress -Name $publicIpAddressName -ResourceGroupName $resourceGroupName -Sku "Basic" -AllocationMethod Dynamic -DomainNameLabel $dnsPrefix -Location $location

Write-Host "Creating a SSHkey service $sshKeyName ..."
New-AzSshKey -ResourceGroupName $resourceGroupName -Name $sshKeyName -PublicKey $sshKeyPublicKey


Write-Host "Creating a VM $vmName ..."

New-AzVm -ResourceGroupName $resourceGroupName -Name $vmName -Location $location -image $vmImage -size $vmSize -PublicIpAddressName $publicIpAddressName -DomainNameLabel $dnsPrefix -OpenPorts 80,22 -SshKeyName $sshKeyName -Verbose