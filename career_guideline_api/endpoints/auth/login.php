<?php
require_once __DIR__ . '/../../config/db.php';
header('Content-Type: application/json');
$pdo = getPDO();
$data = json_decode(file_get_contents("php://input"), true);
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';
$stmt = $pdo->prepare("SELECT * FROM users WHERE email=?");
$stmt->execute([$email]);
$user = $stmt->fetch();
if($user && password_verify($password, $user['password_hash'])){
  echo json_encode(['success'=>true,'user'=>['id'=>$user['id'],'name'=>$user['name'],'email'=>$user['email'],'role'=>$user['role']]]);
}else{
  http_response_code(401);
  echo json_encode(['success'=>false,'message'=>'Invalid credentials']);
}
?>