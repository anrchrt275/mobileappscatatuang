<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host = "localhost";
$user = "root";
$pass = "";
$db = "catatuang_db";

$conn = mysqli_connect($host, $user, $pass, $db);

// Don't output errors directly, just set connection status
if (!$conn) {
    // Connection failed, but don't output anything here
    // Let individual API files handle the error
    $conn = null;
}
?>
