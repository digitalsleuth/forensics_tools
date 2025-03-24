function Create-ImageVM {
	param(
	    [string]$Name = "E01 Image",
        [int32]$Memory = 8589934592,
		[parameter(Mandatory=$true)]
        [int32]$DiskNumber,
		[int32]$ProcessorCount = 4, 
		[int32]$Generation = 2
    )
	$vmExists = (Get-VM -VMName $Name -ErrorAction SilentlyContinue)
	if ($vmExists -ne $null) {
		Stop-VM -VMName $Name -Force
		Remove-VM -VMName $Name -Force
	}
    $Memory = $Memory * [Math]::Pow(1024, 3)
    New-VM -MemoryStartupBytes $Memory -Name $Name -NoVHD -Generation 2
    Set-VM -Name $Name -ProcessorCount $ProcessorCount -AutomaticStartAction Nothing -AutomaticStopAction TurnOff -CheckpointType Disabled -DynamicMemory
    Remove-VMNetworkAdapter -VMName $Name
    Add-VMHardDiskDrive -VMName $Name -DiskNumber $DiskNumber
    Enable-VMIntegrationService -VMName $Name -Name "Guest Service Interface"
    Set-VMFirmware -VMName $Name -EnableSecureBoot Off
    Start-VM -VMName $Name
}
