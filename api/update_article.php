<?php
require 'config.php';

$id = $_POST['id'];
$title = $_POST['title'];
$content = $_POST['content'];
$image_url = $_POST['image_url'];

$sql = "UPDATE articles SET title = '$title', content = '$content', image_url = '$image_url' WHERE id = '$id'";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["status" => "success", "message" => "Artikel berhasil diperbarui"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal memperbarui artikel"]);
}
?>