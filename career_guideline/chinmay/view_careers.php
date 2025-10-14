<?php
include('../connect.php');
$result = mysqli_query($con, "SELECT * FROM chinmay_career");
while($row = mysqli_fetch_assoc($result)) {
    echo $row['career_name'] . " - " . $row['description'] . "<br>";
}
?>
