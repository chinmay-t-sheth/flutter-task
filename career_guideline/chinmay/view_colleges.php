<?php
include('../connect.php');
$result = mysqli_query($con, "SELECT * FROM chinmay_college");
while($row = mysqli_fetch_assoc($result)) {
    echo $row['college_name'] . " - " . $row['stream'] . "<br>";
}
?>
