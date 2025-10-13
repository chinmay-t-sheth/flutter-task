<?php
require_once __DIR__ . '/../../config/db.php';
header('Content-Type: application/json');
$pdo = getPDO();
$stream = $_GET['stream'] ?? '';
$stmt = $pdo->prepare("SELECT * FROM colleges WHERE stream=?");
$stmt->execute([$stream]);
echo json_encode(['success'=>true,'data'=>$stmt->fetchAll()]);
?>