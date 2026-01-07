<?php
require 'config.php';

$email = $_POST['email'];
$password = $_POST['password'];

// Use prepared statement to prevent SQL injection
$stmt = mysqli_prepare($conn, "SELECT * FROM users WHERE email = ?");
mysqli_stmt_bind_param($stmt, "s", $email);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) > 0) {
    $user = mysqli_fetch_assoc($result);
    if (password_verify($password, $user['password'])) {
        echo json_encode([
            "status" => "success",
            "user_id" => $user['id'],
            "name" => $user['name'],
            "email" => $user['email'],
            "profile_image" => $user['profile_image']
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Password salah"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "User tidak ditemukan"]);
}

mysqli_stmt_close($stmt);
?>