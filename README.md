# PowerColorTerm

Helper functions for 24 bit text with PowerShell 6+. Nothing fancy. Just some tags and a tiny bit of regex.

## Usage

First make sure that you imported the Module into your script or profile.

```pwsh
Import-Module PowerColorTerm
```

Now you should have two more commands available, Write-RGB and Get-RGB.
Get-RGB is where the main functionality is happening but is tailored more for scripting.
Write-RGB is a wrapper around Get-RGB and tailored more for general usage.

## Example

```pwsh
Write-RGB '{fg:#FF8C00;bg:#222222}Can {fg:#E81123}your {fg:#0063B1}Shell {fg:#744DA9}also {fg:#fafafa;bg:#10893E}do that?{clc}'
$mycolorfultxt = Get-RGB '{fg:#3691FF}More{clc}     {fg:#ffffff;bg:#9A0089}Colors{clc}      {fg:#ffffff;bg:#E74856}Now'
echo $mycolorfultxt
```