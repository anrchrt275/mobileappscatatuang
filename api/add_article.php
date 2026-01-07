<?php
require 'config.php';

$title = $_POST['title'];
$content = $_POST['content'];
$image_url = $_POST['image_url'];

$sql = "INSERT INTO articles (title, content, image_url) VALUES ('$title', '$content', '$image_url')";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["status" => "success", "message" => "Artikel berhasil ditambahkan"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menambahkan artikel"]);
}
?>