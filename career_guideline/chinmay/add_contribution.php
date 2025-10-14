<?php
include('../connect.php');
$contributor_name = "Guest Contributor";
$title = "Career in SEBI";
$content = "An unconventional but promising career option for finance students.";
$sql = "INSERT INTO chinmay_contribution (contributor_name, title, content)
        VALUES ('$contributor_name','$title','$content')";
if (mysqli_query($con, $sql)) echo "Contribution added successfully!";
else echo "Error: " . mysqli_error($con);
?>
