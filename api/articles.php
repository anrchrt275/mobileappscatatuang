<?php
require 'config.php';

$sql = "SELECT * FROM articles ORDER BY date DESC";
$result = mysqli_query($conn, $sql);

$articles = [];
while ($row = mysqli_fetch_assoc($result)) {
    $articles[] = $row;
}

echo json_encode($articles);
?>