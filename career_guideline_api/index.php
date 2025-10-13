<?php
header('Content-Type: application/json');
echo json_encode([
  "status"=>"Career Guideline API is Running 🚀",
  "available_endpoints"=>[
    "POST /endpoints/auth/register.php",
    "POST /endpoints/auth/login.php",
    "GET /endpoints/careers/get_all.php",
    "GET /endpoints/careers/get_by_id.php?id=1",
    "GET /endpoints/colleges/get_all.php",
    "GET /endpoints/colleges/get_by_stream.php?stream=Science",
    "GET /endpoints/psychometric/get_questions.php",
    "POST /endpoints/psychometric/submit_test.php"
  ]
]);
?>