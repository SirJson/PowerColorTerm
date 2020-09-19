# 24-bit color helper for Write-Host in PowerShell.

<#
 .Synopsis
  Parses the content of a color tag and outputs the required control character.

 .Description
  This function will do the parsing and interpreting of color tag content. This is a private function and the user is not exposed to it.

  .Parameter Data
  A color tag without curly brackets.

  .Example
  Convert-FromColorTag 'fg:#fe00fe'

#>
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
  Converts a tagged string to an ANSI compatible 24-bit color string and returns the result.

 .Description
  This function will match on hex color codes and translate them into ANSI 24 bit control character.
  Foreground colors start with fg: and background colors start with bg. If a color reset inside the provided string is wanted {clc} can be used.
  If both foreground and background color is used the foreground color must be declared first.

  .Parameter Data
  The tagged plain string you want to colorize

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
  Converts a tagged string to an ANSI compatible 24-bit color string and writes the result into stdout via Write-Host.

 .Description
  Converts a tagged string to an ANSI compatible 24-bit color string and writes the result into stdout via Write-Host.
  A color tag is always enclosed between two curly brackets. Color tags that change the foreground color start inside the color tag with fg: and continue with the desired color in hexadecimal RGB.
  See Get-RGB() for a more detailed description and pitfalls on how to tag your input.

  .Parameter Data
  The string to colorize

  .Parameter nol
   If this parameter is set, this command will **not** append your output with a newline character

  .Example
    Write-RGB '{fg:#0000ff;bg:#fefefe}Blue?'
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
