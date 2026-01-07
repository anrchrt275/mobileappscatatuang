<?php
require 'config.php';

echo "=== Database Check ===\n";

// Check database connection
if (!$conn) {
    echo "Database connection: FAILED\n";
    exit;
} else {
    echo "Database connection: SUCCESS\n";
}

// Show all users
echo "\nUsers:\n";
$result = mysqli_query($conn, "SELECT id, name, email FROM users");
while ($row = mysqli_fetch_assoc($result)) {
    echo "ID: {$row['id']}, Name: {$row['name']}, Email: {$row['email']}\n";
}

// Show all transactions
echo "\nTransactions:\n";
$result = mysqli_query($conn, "SELECT id, user_id, type, amount, note, created_at FROM transactions ORDER BY created_at DESC");
while ($row = mysqli_fetch_assoc($result)) {
    echo "ID: {$row['id']}, User: {$row['user_id']}, Type: {$row['type']}, Amount: {$row['amount']}, Note: {$row['note']}, Date: {$row['created_at']}\n";
}
?>
