$input=$args[0]
$output=$args[1]


$path=${Env:ProgramFiles(x86)}
$kit_path=$path+"\Windows Kits"
Get-ChildItem $kit_path -recurse -include "mt.exe" | Foreach-Object { 
    if($_.FullName -like '*x86\*') 
    { 
        echo $_.FullName
        $target=(get-item $_.FullName).Directory.FullName
        echo "Adding to path: $target"
        $env:Path += ";$target"
    }
}

mt.exe -manifest $input -outputresource:$output;