<?php
require 'config.php';

$id = $_POST['id'];

$sql = "DELETE FROM articles WHERE id = '$id'";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["status" => "success", "message" => "Artikel berhasil dihapus"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menghapus artikel"]);
}
?>
