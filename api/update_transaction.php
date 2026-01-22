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
$type = isset($_POST['type']) ? $_POST['type'] : '';
$amount = isset($_POST['amount']) ? $_POST['amount'] : '';
$note = isset($_POST['note']) ? $_POST['note'] : '';

// Validate input
if (empty($id) || empty($user_id) || empty($type) || empty($amount)) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit;
}

// Validate transaction type
if (!in_array($type, ['income', 'expense'])) {
    echo json_encode(["status" => "error", "message" => "Tipe transaksi tidak valid"]);
    exit;
}

// Check database connection
if (!$conn) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

// Use prepared statement to prevent SQL injection
$stmt = mysqli_prepare($conn, "UPDATE transactions SET type = ?, amount = ?, note = ? WHERE id = ? AND user_id = ?");
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Database prepare failed"]);
    exit;
}

mysqli_stmt_bind_param($stmt, "sdsii", $type, $amount, $note, $id, $user_id);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode(["status" => "success", "message" => "Transaksi berhasil diperbarui"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal memperbarui transaksi"]);
}

mysqli_stmt_close($stmt);
?>
