<?php
require 'config.php';

$user_id = $_POST['user_id'];
$name = $_POST['name'];
$email = $_POST['email'];

$sql = "UPDATE users SET name='$name', email='$email' WHERE id='$user_id'";

if (mysqli_query($conn, $sql)) {
    mysqli_query($conn, "INSERT INTO messages (user_id, title, content) VALUES ('$user_id', 'Profil Diperbarui', 'Profil berhasil diperbarui')");
    echo json_encode(["status" => "success", "message" => "Profil berhasil diperbarui"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal memperbarui profil"]);
}
?>