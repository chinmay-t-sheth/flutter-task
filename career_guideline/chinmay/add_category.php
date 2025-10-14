<?php
include('../connect.php');
$category_name = "Science";
$sql = "INSERT INTO chinmay_category (category_name) VALUES ('$category_name')";
if (mysqli_query($con, $sql)) echo "Category added successfully!";
else echo "Error: " . mysqli_error($con);
?>
