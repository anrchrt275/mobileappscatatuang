<?php
// Disable error display to ensure clean JSON output
error_reporting(0);
ini_set('display_errors', 0);

require 'config.php';

// Set content type header
header('Content-Type: application/json');

// Get POST data
$id = isset($_POST['id']) ? $_POST['id'] : '';
$user_id = isset($_POST['user_id']) ? $_POST['user_id'] : '';

// Validate input
if (empty($id) || empty($user_id)) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit;
}

// Check database connection
if (!$conn) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

// Use prepared statement to prevent SQL injection
$stmt = mysqli_prepare($conn, "DELETE FROM transactions WHERE id = ? AND user_id = ?");
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Database prepare failed"]);
    exit;
}

mysqli_stmt_bind_param($stmt, "ii", $id, $user_id);

if (mysqli_stmt_execute($stmt)) {
    if (mysqli_stmt_affected_rows($stmt) > 0) {
        echo json_encode(["status" => "success", "message" => "Transaksi berhasil dihapus"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Transaksi tidak ditemukan atau bukan milik Anda"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menghapus transaksi"]);
}

mysqli_stmt_close($stmt);
?>
