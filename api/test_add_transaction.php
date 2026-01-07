<?php
// Test script for add_transaction.php
error_reporting(0);
ini_set('display_errors', 0);

// Simulate POST request
$_POST['user_id'] = '1';
$_POST['type'] = 'pemasukan';
$_POST['amount'] = '10000';
$_POST['note'] = 'Test transaction';

echo "Testing add_transaction.php...\n";
echo "POST data: user_id=1, type=pemasukan, amount=10000, note=Test transaction\n\n";

// Capture output
ob_start();
include 'add_transaction.php';
$output = ob_get_clean();

echo "Output: $output\n";
echo "Output is valid JSON: " . (json_decode($output) !== null ? 'YES' : 'NO') . "\n";

if (json_decode($output) !== null) {
    $response = json_decode($output, true);
    echo "Status: " . $response['status'] . "\n";
    echo "Message: " . $response['message'] . "\n";
}
?>
