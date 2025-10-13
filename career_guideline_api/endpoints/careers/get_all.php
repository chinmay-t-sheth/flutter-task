<?php
require_once __DIR__ . '/../../config/db.php';
header('Content-Type: application/json');
$pdo = getPDO();
$stmt = $pdo->query("SELECT * FROM careers WHERE approved=1");
echo json_encode(['success'=>true,'data'=>$stmt->fetchAll()]);
?>