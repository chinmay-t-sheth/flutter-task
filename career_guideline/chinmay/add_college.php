<?php
include('../connect.php');
$college_name = "IIT Bombay";
$stream = "Engineering";
$admission_process = "JEE Advanced";
$future_scope = "Excellent placements and research opportunities.";
$sql = "INSERT INTO chinmay_college (college_name, stream, admission_process, future_scope)
        VALUES ('$college_name','$stream','$admission_process','$future_scope')";
if (mysqli_query($con, $sql)) echo "College added successfully!";
else echo "Error: " . mysqli_error($con);
?>
