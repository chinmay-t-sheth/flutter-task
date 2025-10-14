<?php
include('../connect.php');
$student_id = 1;
$score = 85;
$suggestion = "You seem inclined towards analytical subjects like Economics or Engineering.";
$sql = "INSERT INTO chinmay_test_results (student_id, score, suggestion)
        VALUES ('$student_id','$score','$suggestion')";
if (mysqli_query($con, $sql)) echo "Test result saved!";
else echo "Error: " . mysqli_error($con);
?>
