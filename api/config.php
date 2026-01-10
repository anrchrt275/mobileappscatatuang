<?php
// Tetapkan header CORS global
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE, PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$host = "localhost";
$user = "bere9277_user_rio";
$pass = "Anrchrt_0527";
$db = "bere9277_db_rio";

$conn = mysqli_connect($host, $user, $pass, $db);

// Don't output errors directly, just set connection status
if (!$conn) {
    // Connection failed, but don't output anything here
    // Let individual API files handle the error
    $conn = null;
}
?>