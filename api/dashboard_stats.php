<?php
require 'config.php';

$user_id = $_GET['user_id'];

$q_pemasukan = mysqli_query($conn, "SELECT SUM(amount) as total FROM transactions WHERE user_id = '$user_id' AND type = 'income'");
$pemasukan = mysqli_fetch_assoc($q_pemasukan)['total'] ?? 0;

$q_pengeluaran = mysqli_query($conn, "SELECT SUM(amount) as total FROM transactions WHERE user_id = '$user_id' AND type = 'expense'");
$pengeluaran = mysqli_fetch_assoc($q_pengeluaran)['total'] ?? 0;

$saldo = $pemasukan - $pengeluaran;

echo json_encode([
    "saldo" => $saldo,
    "pemasukan" => (double) $pemasukan,
    "pengeluaran" => (double) $pengeluaran
]);
?>