<?php
require 'config.php';

// Test database connection
if ($conn) {
    echo "Database connection: SUCCESS\n";
    
    // Test if users table exists
    $result = mysqli_query($conn, "SHOW TABLES LIKE 'users'");
    if (mysqli_num_rows($result) > 0) {
        echo "Users table: EXISTS\n";
        
        // Count users
        $result = mysqli_query($conn, "SELECT COUNT(*) as count FROM users");
        $row = mysqli_fetch_assoc($result);
        echo "Total users: " . $row['count'] . "\n";
    } else {
        echo "Users table: NOT FOUND - Please run setup_database.sql\n";
    }
    
    // Test API endpoints
    echo "\nTesting API endpoints:\n";
    
    // Test login endpoint
    echo "1. Login endpoint: ";
    $ch = curl_init('http://localhost/api/login.php');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, ['email' => 'test@test.com', 'password' => 'test']);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode == 200) {
        echo "RESPONDING (HTTP 200)\n";
        echo "   Response: " . substr($response, 0, 100) . "...\n";
    } else {
        echo "NOT RESPONDING (HTTP $httpCode)\n";
    }
    
} else {
    echo "Database connection: FAILED\n";
    echo "Error: " . mysqli_connect_error() . "\n";
}
?>
