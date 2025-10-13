<?php
function getPDO(){
  $host = "localhost";
  $db   = "career_guideline";
  $user = "root";
  $pass = "";
  $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
  $opt = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
  ];
  return new PDO($dsn, $user, $pass, $opt);
}
?>