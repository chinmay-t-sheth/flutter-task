<?php
require_once __DIR__ . '/../../config/db.php';
header('Content-Type: application/json');
$pdo = getPDO();
$data = json_decode(file_get_contents("php://input"), true);
$name = trim($data['name'] ?? '');
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';
if(!$name || !$email || !$password){
  http_response_code(400);
  echo json_encode(['success'=>false, 'message'=>'All fields are required']);
  exit;
}
$stmt = $pdo->prepare("SELECT id FROM users WHERE email=?");
$stmt->execute([$email]);
if($stmt->fetch()){
  http_response_code(409);
  echo json_encode(['success'=>false, 'message'=>'Email already exists']);
  exit;
}
$hash = password_hash($password, PASSWORD_BCRYPT);
$stmt = $pdo->prepare("INSERT INTO users (name,email,password_hash,role) VALUES (?,?,?,?)");
$stmt->execute([$name, $email, $hash, 'student']);
echo json_encode(['success'=>true, 'message'=>'Registered successfully']);
?>