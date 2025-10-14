<?php
include('../connect.php');
$student_id = 1;
$question_text = "What are career options after B.Com?";
$sql = "INSERT INTO chinmay_question (student_id, question_text)
        VALUES ('$student_id','$question_text')";
if (mysqli_query($con, $sql)) echo "Question posted successfully!";
else echo "Error: " . mysqli_error($con);
?>
