# Name: FormatDataDisks
#
configuration FormatDataDisks 
{ 
      param (
         $Disks
    ) 

    #$DiskArray = $Disks | convertfrom-Json $disks
   
    node localhost
    {
       
        Script FormatVolumnes
        {
            GetScript = {
              get-disk
              Get-Partition
            }
            SetScript = {
               try {
                
                # Initialize All
                Get-Disk | ?{$_.PartitionStyle -eq "Raw"} | ?{$_.number -ne 0}| Initialize-Disk -PartitionStyle GPT

                #format the ones requested
                foreach($disk in $using:Disks.values) {

                    $partArray = Get-Partition
                    
                    #remove any non-lettered partitions
                    $(Get-Partition |? {if($_.DriveLetter -notmatch "[A-Z]" -and $_.DiskNumber -gt 1 -and $_.Type -ne "IFS" ){$_} }) | Remove-Partition -Confirm:$false

                    #Get the list of whats left
                    $UsedDiskArray = $(Get-Partition | ?{$_.DiskNumber -gt 1} | Select DiskNumber -Unique)

                    $thisExists =$partArray  | Where-Object {$_.DriveLetter -eq $($disk.DiskName)} | Select -First 1
        
                    if($thisExists -eq $null) {
                        
                       $DiskExists =   get-disk  | ? {$_.Number -notin $UsedDiskArray.DiskNumber} | ? {$($_.Size/1GB) -eq $($disk.Disksize) }  | Sort-Object DiskNumber | select -First 1
                      
                        try {
                            if($DiskExists) {      
                            
                                if($DiskExists.PartitionStyle -eq 'Raw') {
                                       Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter $($disk.DiskName) -UseMaximumSize -DiskNumber $($DiskExists.Number) | Format-Volume -NewFileSystemLabel $($disk.DiskLabel) -FileSystem NTFS -AllocationUnitSize 65536 -Confirm:$false -Force     
                                    } else {
                                       New-Partition -DriveLetter $($disk.DiskName) -UseMaximumSize -DiskNumber $($DiskExists.Number) | Format-Volume -NewFileSystemLabel $($disk.DiskLabel) -FileSystem NTFS -AllocationUnitSize 65536 -Confirm:$false -Force
                                    } 
                          
                            } else {
                                write-verbose "No Drive avail"
                            }
                        } catch {
                                write-verbose  "`t[FAIL] $VM Setting Drive $($Disk.DiskName) Failed.`n"
                        
                        }

                    } else {
                        Write-verbose "`t[PASS] $VM Drive $($Disk.DiskName) exists.`n"
                    }
                }

                #format the remaining using next available drive letter
                get-disk | ? {$_.PartitionStyle -eq 'Raw'} | %{ Initialize-Disk -PartitionStyle GPT -Number $_.number -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -Confirm:$false  }   

               } catch {}
            }
            TestScript = {
                 $diskArray = get-disk | ? {$_.PartitionStyle -eq 'RAW'}
                 $partArray = Get-Partition

                 $vols =@()
                 $disks | ? {
                    $d=$_
                    $v =  $($partArray  | Where-Object {$_.DriveLetter -eq $($d.DiskName)} | Select -First 1)
                    if(!$v){
                        $vols+=$d
                    }
                 }

            if($vols) {return $true} else {return $false}
            }    
            
        }

      }

    }
