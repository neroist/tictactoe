# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# clear terminal, to give a "clean" look
Clear-Host

# set current directory to batch file directory
$ScriptPath = $MyInvocation.MyCommand.Path
$Dir = Split-Path $ScriptPath

Set-Location $Dir

# delete previous json, csv, and exe files
Remove-Item "*.json"
Remove-Item "*.csv"
Remove-Item "*.exe"

# compile and run data collection program
nim.exe -x:off r collection.nim

# wait a bit
Start-Sleep -Milliseconds 750

# generate graphs
[string] $PythonScriptArgs = ("python", "py", "matplotlib", "qt", "gui", "snake")

if ( $PythonScriptArgs.contains($args[0]) -and $args[0] ) {
    python.exe "graph.py"
} else {
    nim.exe r graph.nim
}
