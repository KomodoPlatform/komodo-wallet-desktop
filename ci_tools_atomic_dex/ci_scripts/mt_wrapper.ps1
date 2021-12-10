$input=$args[0]
$output=$args[1]

echo $input $output
mt.exe -manifest $input -outputresource:$output;#1