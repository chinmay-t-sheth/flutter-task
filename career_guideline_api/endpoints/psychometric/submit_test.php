<?php
require_once __DIR__ . '/../../config/db.php';
header('Content-Type: application/json');
$pdo = getPDO();
$data = json_decode(file_get_contents("php://input"), true);
$user_id = intval($data['user_id'] ?? 0);
$answers = $data['answers'] ?? [];
$score = 0;
foreach($answers as $q_id => $ans){
  $stmt = $pdo->prepare("SELECT correct_option FROM psychometric_questions WHERE id=?");
  $stmt->execute([$q_id]);
  $row = $stmt->fetch();
  if($row && strtoupper($row['correct_option']) == strtoupper($ans)){
    $score++;
  }
}
$stmt = $pdo->prepare("INSERT INTO psychometric_results (user_id, score) VALUES (?,?)");
$stmt->execute([$user_id, $score]);
echo json_encode(['success'=>true,'score'=>$score]);
?>