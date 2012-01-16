<!-- PHP Wrapper - 500 Server Error -->
<html><head><title>500 Server Error</title></head>
<body bgcolor=white>
<h1>500 Server Error</h1>

A misconfiguration on the server caused a hiccup.
Check the server logs, fix the problem, then try again.
<hr>

<?php
echo "URL: http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]<br>\n";
echo `checksuexec`;
?>

</body></html>
