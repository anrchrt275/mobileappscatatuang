<?php
require 'config.php';

$user_id = $_GET['user_id'];

$sql = "SELECT * FROM transactions WHERE user_id = '$user_id' ORDER BY date DESC";
$result = mysqli_query($conn, $sql);

$transactions = [];
while ($row = mysqli_fetch_assoc($result)) {
    $transactions[] = $row;
}

echo json_encode($transactions);
?>