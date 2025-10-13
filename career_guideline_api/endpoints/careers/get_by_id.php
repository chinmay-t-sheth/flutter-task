<?php
require_once __DIR__ . '/../../config/db.php';
header('Content-Type: application/json');
$pdo = getPDO();
$id = intval($_GET['id'] ?? 0);
$stmt = $pdo->prepare("SELECT * FROM careers WHERE id=? AND approved=1");
$stmt->execute([$id]);
echo json_encode(['success'=>true,'data'=>$stmt->fetch()]);
?>