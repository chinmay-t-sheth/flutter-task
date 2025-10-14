<?php
include('../connect.php');
$question_id = 1;
$contributor_id = 2;
$answer_text = "You can pursue MBA, CA, or Data Analytics.";
$sql = "INSERT INTO chinmay_answer (question_id, contributor_id, answer_text)
        VALUES ('$question_id','$contributor_id','$answer_text')";
if (mysqli_query($con, $sql)) echo "Answer posted successfully!";
else echo "Error: " . mysqli_error($con);
?>
