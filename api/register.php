<?php
require 'config.php';

$name = $_POST['name'];
$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);

$sql = "INSERT INTO users (name, email, password) VALUES ('$name', '$email', '$password')";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["status" => "success", "message" => "Akun berhasil dibuat"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal mendaftar: " . mysqli_error($conn)]);
}
?>