<?php
require 'config.php';

$user_id = $_GET['user_id'];

$sql = "SELECT * FROM messages WHERE user_id = '$user_id' ORDER BY date DESC";
$result = mysqli_query($conn, $sql);

$messages = [];
while ($row = mysqli_fetch_assoc($result)) {
    $messages[] = $row;
}

echo json_encode($messages);
?>