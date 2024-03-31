# Define the list of VM sizes
#$vmSizes = @("Standard_D2s_v3", "Standard_D4s_v3", "Standard_D8s_v3")
$vmSizes = Get-Content -Path ./vmSize
# Define other parameters
$location = "West Europe"
$adminUsername = "azureuser"
$adminPassword = "Fujitsu20191"
$bicepFile = "./vm.bicep"
# Read the public key from the file
$publicKey = Get-Content -Path ./vmtesting.pub

# Loop over the VM sizes
for ($i=0; $i -lt 5; $i++) {
    foreach ($vmSize in $vmSizes) {
        # Derive the VM name from the VM size by replacing underscore with empty string
        $vmName = $vmSize -replace "_", ""

        # Recreate the resource group
        az group create --name $vmName  --location $location

        # Deploy the Bicep template
        az deployment group create `
            --name "${vmName}_${vmSize}" `
            --resource-group $vmName `
            --template-file $bicepFile `
            --mode Complete `
            --parameters vmName=$vmName vmSize=$vmSize location=$location adminUsername=$adminUsername sshPublicKey=$publicKey adminPassword=$adminPassword
        # Get the public IP of the VM
        $vmIp = (az vm show -d -g $vmName -n $vmName --query publicIps -o tsv)
        
        # Define the SCP command to copy the script to the remote machine
        $scpCommand = "C:\Windows\System32\OpenSSH\scp.exe -i ./vmtesting.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ./script.sh "+$adminUsername+"@"+$vmIp+":~/"

        # Use the SCP command to copy the script
        Invoke-Expression $scpCommand

        # Define the SSH command
        $sshCommand = "C:\Windows\System32\OpenSSH\ssh.exe -i ./vmtesting.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "+$adminUsername+"@"+$vmIp

        Invoke-Expression "$sshCommand 'bash ~/script.sh'"
        
        # Delete the resource group if it exists     
        az group delete --name $vmName --yes --no-wait
    }
}