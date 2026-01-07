<?php
require 'config.php';

echo "=== Debug Transactions ===\n";

// Check if database connection works
if (!$conn) {
    echo "Database connection: FAILED\n";
    exit;
} else {
    echo "Database connection: SUCCESS\n";
}

// Check if transactions table exists
$result = mysqli_query($conn, "SHOW TABLES LIKE 'transactions'");
if (mysqli_num_rows($result) > 0) {
    echo "Transactions table: EXISTS\n";
} else {
    echo "Transactions table: NOT FOUND\n";
    exit;
}

// Count total transactions
$result = mysqli_query($conn, "SELECT COUNT(*) as count FROM transactions");
$row = mysqli_fetch_assoc($result);
echo "Total transactions: " . $row['count'] . "\n";

// Show all transactions
$result = mysqli_query($conn, "SELECT * FROM transactions ORDER BY created_at DESC LIMIT 5");
if (mysqli_num_rows($result) > 0) {
    echo "\nRecent transactions:\n";
    while ($row = mysqli_fetch_assoc($result)) {
        echo "ID: {$row['id']}, User: {$row['user_id']}, Type: {$row['type']}, Amount: {$row['amount']}, Note: {$row['note']}, Date: {$row['created_at']}\n";
    }
} else {
    echo "\nNo transactions found\n";
}

// Test API with user_id=1
echo "\n=== Testing API ===\n";
$_GET['user_id'] = '1';

// Capture output
ob_start();
include 'transactions.php';
$output = ob_get_clean();

echo "API Output: $output\n";
echo "Is valid JSON: " . (json_decode($output) !== null ? 'YES' : 'NO') . "\n";

// Check if user_id=1 exists
$result = mysqli_query($conn, "SELECT * FROM users WHERE id = 1");
if (mysqli_num_rows($result) > 0) {
    echo "User ID 1: EXISTS\n";
} else {
    echo "User ID 1: NOT FOUND\n";
    
    // Show all users
    $result = mysqli_query($conn, "SELECT id, name, email FROM users");
    if (mysqli_num_rows($result) > 0) {
        echo "Available users:\n";
        while ($row = mysqli_fetch_assoc($result)) {
            echo "ID: {$row['id']}, Name: {$row['name']}, Email: {$row['email']}\n";
        }
    }
}
?>
