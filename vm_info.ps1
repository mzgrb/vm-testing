# Import the Az module
# Import-Module Az.Compute

# Login to your Azure account
# Connect-AzAccount

# Create an empty array to store the output
$output = @()

# Read the vmSize file line by line
Get-Content vmSize | ForEach-Object {
    $vmSize = $_

    # Get the VM size details from Azure
    $vmDetails = Get-AzVMSize -Location westeurope | Where-Object {$_.Name -eq $vmSize}

    # Add the vmSize, number of cores, and memory to the output array
    $output += "$($vmDetails.Name),$($vmDetails.NumberOfCores),$($vmDetails.MemoryInMB)"
}

# Save the output to a file
$output | Out-File -FilePath output.csv