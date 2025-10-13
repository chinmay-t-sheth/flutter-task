<?php
require_once __DIR__ . '/../../config/db.php';
header('Content-Type: application/json');
$pdo = getPDO();
$stmt = $pdo->query("SELECT id, question, option_a, option_b, option_c, option_d FROM psychometric_questions");
echo json_encode(['success'=>true,'questions'=>$stmt->fetchAll()]);
?>