<?php
include('../connect.php');
$email = "riya@gmail.com";
$password = "12345";
$sql = "SELECT * FROM chinmay_login WHERE email='$email' AND password='$password'";
$result = mysqli_query($con, $sql);
if (mysqli_num_rows($result) > 0) echo "Login successful!";
else echo "Invalid credentials!";
?>
