<?php
require 'config.php';

$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);

$update = mysqli_query($conn, "UPDATE users SET password='$password' WHERE email='$email'");

if ($update) {
    mysqli_query(
        $conn,
        "INSERT INTO messages (user_id, title, content)
       SELECT id, 'Password Diperbarui', 'Password berhasil diperbarui'
       FROM users WHERE email='$email'"
    );
    echo json_encode(["status" => "success", "message" => "Password berhasil diperbarui"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal reset password"]);
}
?>