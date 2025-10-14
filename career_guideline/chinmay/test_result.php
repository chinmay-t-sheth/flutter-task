<?php
include('../connect.php');
$result = mysqli_query($con, "SELECT * FROM chinmay_test_results");
while($row = mysqli_fetch_assoc($result)) {
    echo "Student ID: " . $row['student_id'] . " - Score: " . $row['score'] .
         " - Suggestion: " . $row['suggestion'] . "<br>";
}
?>
