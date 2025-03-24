Function Mount-VSC {
<#
    .SYNOPSIS
        Mount a volume shadow copy.
        Original Source for this script found at https://p0w3rsh3ll.wordpress.com/2014/06/21/mount-and-dismount-volume-shadow-copies/
        Posted by Emin Atac. Modified for rapid use.
     
    .DESCRIPTION
        Mount a volume shadow copy. Verbose enabled by default.
      
    .PARAMETER Destination
        Target folder that will contain mounted volume shadow copies
              
    .EXAMPLE
        Mount-VSC -Destination C:\VSS 
 
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]$Destination
)
Begin {
    Try {
        $null = [mklink.symlink]
    } Catch {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;
  
        namespace mklink
        {
            public class symlink
            {
                [DllImport("kernel32.dll")]
                public static extern bool CreateSymbolicLink(string lpSymlinkFileName, string lpTargetFileName, int dwFlags);
            }
        }
"@
    }
}
Process {
    $oldVerbose = $VerbosePreference
    $VerbosePreference = "Continue"
    $ShadowPath = Get-CimInstance -ClassName Win32_ShadowCopy
    $ShadowPath.DeviceObject | ForEach-Object -Process {
 
        if ($($_).EndsWith("\")) {
            $sPath = $_
        } else {
            $sPath = "$($_)\"
        }
        
        $tPath = Join-Path -Path $Destination -ChildPath (
        '{0}-{1}' -f (Split-Path -Path $sPath -Leaf),[GUID]::NewGuid().Guid
        )
         
        try {
            if (
                [mklink.symlink]::CreateSymbolicLink($tPath,$sPath,1)
            ) {
                Write-Verbose -Message "Successfully mounted $sPath to $tPath"
            } else  {
                Write-Warning -Message "Failed to mount $sPath"
            }
        } catch {
            Write-Warning -Message "Failed to mount $sPath because $($_.Exception.Message)"
        }
    }
 $VerbosePreference = $oldVerbose
}
End {}
}
 
Function Unmount-VSC {
<#
    .SYNOPSIS
        Unmount a volume shadow copy.
     
    .DESCRIPTION
        Unmount a volume shadow copy.
      
    .PARAMETER Path
        Path of volume shadow copies mount points
      
    .EXAMPLE
        Unmount-VSC -Path C:\vss
         
 
#>
 
[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [Alias("FullName")]
    [string[]]$Path
)
Begin {
}
Process {
    $oldVerbose = $VerbosePreference
    $VerbosePreference = "Continue"
    $Path = (Get-ChildItem $Path).FullName  | ForEach-Object -Process {
        $sPath =  $_
        if (Test-Path -Path $sPath -PathType Container) {
            if ((Get-Item -Path $sPath).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                try {
                    [System.IO.Directory]::Delete($sPath,$false) | Out-Null
                    Write-Verbose -Message "Successfully dismounted $sPath"
                } catch {
                    Write-Warning -Message "Failed to dismount $sPath because $($_.Exception.Message)"
                }
            } else {
                Write-Warning -Message "The path $sPath isn't a reparsepoint"
            }
        } else {
            Write-Warning -Message "The path $sPath isn't a directory"
        }
     }
     $VerbosePreference = $oldVerbose
}
End {}
}