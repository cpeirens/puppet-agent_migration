$to_fqdn=$args[0]

$confdir = "C:/ProgramData/PuppetLabs/puppet/etc"
$ssldir = $confdir + "/ssl"

# update the server and archive_file_server settings with the new puppet master fqdn
# remove the enviroment setting
(((Get-Content ($confdir + "/puppet.conf") | Foreach-Object {$_ -replace '^server.+', ("server=" + $to_fqdn)}) | Foreach-Object {$_ -replace '^archive_file_server.+', ("archive_file_server=" + $to_fqdn)}) | Where-Object {$_ -notmatch '^environment.+'}) | Set-Content ($confdir + "/puppet.conf")

# remove the ssl directory and all contents
Remove-Item -Recurse -Force $ssldir
