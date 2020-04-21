# 24-bit color helper for Write-Host in PowerShell.

function Convert-FromColorTag {
    param (
        [Parameter(Mandatory)]
        [string] $tag
    )
    $esc = [char]0x1b
    $mode = "38"
    $modestr = $tag.Substring(0, 3)
    if ($modestr -eq "bg:") {
        $mode = "48"
    }
    $red = [Convert]::ToUInt16($tag.Substring(4, 2), 16)
    $green = [Convert]::ToUInt16($tag.Substring(6, 2), 16)
    $blue = [Convert]::ToUInt16($tag.Substring(8, 2), 16)


    return "$esc[$mode;2;$red;$green;$blue" + "m"
}

<#
 .Synopsis
  Converts a taged string to an ansi compatible 24-bit color string and returns the result.

 .Description
  Converts a taged string to an ansi compatible 24-bit color string and returns the result.
  This function will match hex color codes and translate them into ansi 24 bit control chars.
  Foreground colors start with fg:, Background colors start with bg. If a color reset inside the provided string is wanted {clc} can be used.
  If both foreground and background color is used the foreground color must be first.

  .Parameter Data
  The tagged string to convert

  .Example
    Get-RGB '{fg:#ff0000;bg:#ffffff}Kinda red{clc} {fg:#00ff00}Kinda green'
#>
function Get-RGB {
    param (
        [Parameter(Mandatory)]
        [string] $data
    )
    $esc = [char]0x1b
    $endctl = "$esc[0;m"
    [Regex]$tagpattern = '\{(fg:[#a-fA-F0-9]+)?;?(bg:[#a-fA-F0-9]+)?\}|(\{clc\})+?|([^\{\}]+)'
    $result = $tagpattern.Matches($data)

    $builder = [System.Text.StringBuilder]::new()

    foreach ($match in $result) {
        if ($match.Groups[2].Success) {
            [void] $builder.Append((Convert-FromColorTag $match.Groups[2].Value))
        }
        if ($match.Groups[1].Success) {
            [void] $builder.Append((Convert-FromColorTag $match.Groups[1].Value))
        }
        if ($match.Groups[4].Success) {
            [void] $builder.Append($match.Groups[4].Value)
        }
        if ($match.Groups[3].Success) {
            [void] $builder.Append($endctl)
        }
    }
    [void] $builder.Append($endctl)
    return $builder.ToString()
}

<#
 .Synopsis
  Converts a taged string to an ansi compatible 24-bit color string and prints the result via Write-Host.

 .Description
  Converts a taged string to an ansi compatible 24-bit color string and prints the result via Write-Host.
  See Get-RGB() for information on how to tag the input string

  .Parameter Data
  The tagged string to convert

  .Parameter nol
  If set no new line will be printed

  .Example
    Write-RGB '{fg:#0000ff;bg:#fefefe}servus'
#>
function Write-RGB {
    param (
        [Parameter(Mandatory)]
        [string] $data,
        [Parameter(Mandatory = $false)]
        [Switch] $nol
    )
    $rgbtxt = Get-RGB $data
    if ($nol) {
        Write-Host -NoNewline $rgbtxt
    }
    else {
        Write-Host $rgbtxt
    }
}

Export-ModuleMember -Function Write-RGB
Export-ModuleMember -Function Get-RGB
