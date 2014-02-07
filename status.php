<?php

$TITLE   = 'Status Hamster';
$VERSION = '0.1';

echo <<<EOT
<!DOCTYPE HTML>
<html lang="en-US">
<head>
	<meta charset="UTF-8">
	<title>$TITLE</title>
</head>
<body style="background-color: #000000; color: #FFFFFF; font-weight: bold; padding: 0 10px;">
<pre>
  o-o    $TITLE
 /\\"/\   v$VERSION
(`=*=') 
 ^---^`-.


EOT;

$allowed_ips = array('195.37.139.','193.174.');
$allowed = false;
$headers = apache_request_headers();
if (@$headers["X-Forwarded-For"]) {
    $ips = explode(",",$headers["X-Forwarded-For"]);
    $ip  = $ips[0];
} else {
    $ip = $_SERVER['REMOTE_ADDR'];
}
foreach ($allowed_ips as $allow) {
    if (stripos($ip, $allow) !== false) {
        $allowed = true;
        break;
    }
}
if (!$allowed) {
	header('HTTP/1.1 403 Forbidden');
 	echo "<span style=\"color: #ff0000\">Sorry, no hamster - better convince your parents!</span>\n";
    echo "</pre>\n</body>\n</html>";
    exit;
}

flush();

$command = 'git status';
$log = shell_exec("$command 2>&1");

echo htmlentities(trim($command))."\n";
$log = preg_replace('/^([^,]+),[^-]+-/m','\1 -',$log); # remove proxy IP
$log = preg_replace('/password=[^ &]*/','password=XXXX',$log);
echo htmlentities(trim($log));

?>
</pre>
</body>
</html>
