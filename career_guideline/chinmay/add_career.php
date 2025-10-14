<?php
include('../connect.php');
$category_id = 1;
$career_name = "Data Scientist";
$description = "A career in data science focuses on analyzing and interpreting complex data.";
$sql = "INSERT INTO chinmay_career (category_id, career_name, description)
        VALUES ('$category_id','$career_name','$description')";
if (mysqli_query($con, $sql)) echo "Career added successfully!";
else echo "Error: " . mysqli_error($con);
?>
