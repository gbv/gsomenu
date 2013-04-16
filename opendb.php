<?php
$dbsid = preg_match('/^[0-9.]+$/',@$_GET['db']) ? $_GET['db'] : '2.1';
$url = "http://gso.gbv.de/DB=$dbsid/";

header("Location: $url",TRUE,302); // 302: Found

echo "<!DOCTYPE html><html><head><meta http-equiv='refresh' content='0;url=$url'/></head></html>";
