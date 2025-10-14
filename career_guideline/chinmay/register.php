<?php
include('../connect.php');
$name = "Riya Sharma";
$email = "riya@gmail.com";
$password = "12345";
$role = "student";
$sql = "INSERT INTO chinmay_login (name, email, password, role)
        VALUES ('$name','$email','$password','$role')";
if (mysqli_query($con, $sql)) echo "Registration successful!";
else echo "Error: " . mysqli_error($con);
?>
