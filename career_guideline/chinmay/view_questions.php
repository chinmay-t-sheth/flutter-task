<?php
include('../connect.php');
$result = mysqli_query($con, "SELECT * FROM chinmay_question");
while($row = mysqli_fetch_assoc($result)) {
    echo $row['id'] . ". " . $row['question_text'] . "<br>";
}
?>
