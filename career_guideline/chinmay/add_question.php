<?php
include('../connect.php');
$question_text = "Do you enjoy solving math problems?";
$sql = "INSERT INTO chinmay_test_questions (question_text) VALUES ('$question_text')";
if (mysqli_query($con, $sql)) echo "Test question added!";
else echo "Error: " . mysqli_error($con);
?>
