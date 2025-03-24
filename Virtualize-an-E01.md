## How to Virtualize an E01 with Hyper-V

1. Confirm that you have Arsenal Image Mounter installed.
2. Confirm that Hyper-V is enabled on the local system by clicking the Start menu and typing “features”, then select “Turn Windows features on or off”.
3. In the list which comes up, make sure that the checkbox for Hyper-V is fully clicked and not partially or completely unchecked. Click OK.
4. If the system asks you to reboot, say NO unless you already have Arsenal Image Mounter installed AND have mounted an image at least once with it.
5. Open Arsenal Image Mounter. Click OK on the splash screen. On first boot, it will ask you to install the drivers necessary to create virtual disks. Click "Yes" to install the driver now.
6. When prompted to reboot, click OK. If you don't get a warning to install the driver and reboot to continue, then proceed to the next step without rebooting.
7. Once logged back in, open Arsenal Image Mounter, click OK at the splash screen, and click "Mount disk image" at the bottom.
8. Browse to the E01 you wish to mount and click "Open". 
9. On the "Mount options" window that comes up, select the option for "Disk device, write temporary". The other options are not necessary at this time. Click OK.
10. Once the disk is mounted, Windows may try to open File Explorer windows to the newly mounted drives, or warn you that a drive needs to be formatted. Close these File Explorer windows, and do not attempt to format any volumes (click "Cancel").
11. Back in Arsenal Image Mounter, expand the disk image by clicking the + icon on the left. Make a note of the "Disk device" value. It will say something along the lines of "PhysicalDrive#" where "#" is a number.
12. With the disk image selected in Arsenal Image Mounter, click the "Advanced" menu at the top, and click "Offline disk".
13. Minimize Arsenal Image Mounter, and click the Start button and type "Hyper". You will see "Hyper-V Manager" as an option in the list. Click it to open it.
14. Under "Hyper-V Manager" on the left side, you will see an entry for the computer name of YOUR computer. If it's not already selected, click on it.
15. On the "Actions" tab on the right hand side of the window, click on "New... -> Virtual Machine..." to open the "New Virtual Machine Wizard".
16. On the "Before You Begin" screen, click "Next".
17. On the "Specify Name and Location" screen, create a Name for the virtual machine, and click the checkbox for "Store the virtual machine in a different location" IF you want to change its destination. Browse to the new location and click OK. Otherwise, leave this box unchecked and click "Next".

---- The following settings will depend on the specs of the machine for the image which was acquired. These settings will work with most modern OSes. ----

18. On the "Specify Generation" screen, select "Generation 2" and click "Next.
19. On the "Assign Memory" screen, choose at least 2048 MB of memory or higher, and leave the "Use Dynamic Memory" feature checked. Click Next.
20. On the "Configure Networking" screen, leave the "Connection" set to "Not Connected", so the VM doesn't have access to the internet.Click Next.
21. On the "Connect Virtual Hard Disk" screen, click "Attach a virtual hard disk later" and click Next.
22. On the "Completing the New Virtual Machine Wizard" screen, click Finish.
23. Back in the "Hyper-V Manager" window, you should now see your new VM. Click once on the VM, then on the right hand side under "Actions - <your_VM_name>", click "Settings...".
24. On the "Settings for <your_VM_name>" window, click on "Security" and UNCHECK "Enable Secure Boot" and click "Apply".
25. Click "SCSI Controller" on the left, and on the right hand side click "Hard Drive" and select "Add".
26. On the "Hard Drive" window, click "Physical hard disk" at the bottom, and click the drop-down box to select the Disk # which matches the "PhysicalDrive" you noted earlier. Click "Apply".
27. Click "Firmware" on the left, and click the newly added "Hard Drive" and select "Move Up". Then click "Apply".
28. Click "Integration Services" on the left, and ensure every box is checked. Click "Apply".
29. Click "Checkpoints" on the left, and UNCHECK "Enable checkpoints". Click "Apply".
30. Click "Automatic Start Action" on the left, and click "Nothing". Click "Apply".
31. Click "Automatic Stop Action" on the left, and click "Turn off the virtual machine". Click "Apply".
32. Click OK.
33. Back on the "Hyper-V Manager" window, you can double-click your VM, then click "Start" to start it up.