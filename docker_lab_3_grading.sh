#!/bin/bash
docker load < /mysql.tar
docker run -d --name nilaisql -e MYSQL_ROOT_PASSWORD=1234 -p 3307:3306 mysql
# Meminta ID siswa
read -p "Masukkan ID siswa: " student_id

# Skor awal
score=0
max_score=2100  # Total skor untuk semua tugas

# Fungsi untuk memeriksa apakah perintah sudah dijalankan
check_command_executed() {
    task_description=$1
    command=$2
    task_points=$3

    if grep -q "$command" ~/.ash_history; then
        echo "$task_description: Command found ✔"
        score=$((score + task_points))
    else
        echo "$task_description: Command not found ✖"
    fi
}

# Fungsi untuk memeriksa apakah container berjalan
check_container_running() {
    container_name=$1
    task_points=$2

    if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
        echo "Container $container_name is running ✔"
        score=$((score + task_points))
    else
        echo "Container $container_name is not running ✖"
    fi
}

# Fungsi untuk memeriksa apakah image sudah ter-pull
check_image_pulled() {
    image_name=$1
    task_points=$2

    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$image_name"; then
        echo "Image $image_name is pulled ✔"
        score=$((score + task_points))
    else
        echo "Image $image_name is not pulled ✖"
    fi
}

# Grading untuk Practice I
echo "Grading Practice I tasks..."

# Task 1: Search image nginx
check_command_executed "1. Search image nginx" "docker search nginx" 100

# Task 2: Running image nginx image with the name nginx1 and expose port 8080
check_command_executed "2. Running nginx1 container with port 8080 exposed" "docker run -d --name nginx1 -p 8080:80 nginx" 50
check_container_running "nginx1" 50

# Task 3: Display a description of the nginx1 container
check_command_executed "3. Display a description of the nginx1 container" "docker inspect nginx1" 100

# Task 4: Running an nginx image with the name nginx2 and expose port 8081
check_command_executed "4. Running nginx2 container with port 8081 exposed" "docker run -d --name nginx2 -p 8081:80 nginx" 50
check_container_running "nginx2" 50

# Task 5: Display containers
check_command_executed "5. Display containers" "docker ps -a" 50
check_command_executed "5. Display containers" "docker container ls -a" 50

# Task 6: Check nginx output on containers
check_command_executed "6. Check nginx output on container nginx1" "curl localhost:8080" 50
check_command_executed "6. Check nginx output on container nginx2" "curl localhost:8081" 50

# Task 7: Accessing the container nginx2
check_command_executed "7. Accessing the container nginx2" "docker exec -it nginx2 /bin/bash" 100

# Task 11: Rerun the container nginx2
check_command_executed "11. Start the container nginx2" "docker start nginx2" 50

# Task 12: Display a description of the containers
check_command_executed "12. Display a description of the nginx1 container" "docker inspect nginx1" 50
check_command_executed "12. Display a description of the nginx2 container" "docker inspect nginx2" 50

# Task 13: Check nginx output on containers
check_command_executed "13. Check nginx output on container nginx1" "curl localhost:8080" 50
check_command_executed "13. Check nginx output on container nginx2" "curl localhost:8081" 50

# Task 14: Display the log content of the containers
check_command_executed "14. Display the log content of nginx1" "docker logs nginx1" 50
check_command_executed "14. Display the log content of nginx2" "docker logs nginx2" 50

# Task 15: Display a description of the containers
check_command_executed "15. Display a description of the nginx1 container" "docker inspect nginx1" 50
check_command_executed "15. Display a description of the nginx2 container" "docker inspect nginx2" 50

# Task 16: Display the live resources used in the containers
check_command_executed "16. Display the live resources used in nginx1" "docker stats nginx1" 50
check_command_executed "16. Display the live resources used in nginx2" "docker stats nginx2" 50

# Task 17: Display running processes in containers
check_command_executed "17. Display running processes in nginx1" "docker top nginx1" 50
check_command_executed "17. Display running processes in nginx2" "docker top nginx2" 50

# Grading untuk Practice II
echo "Grading Practice II tasks..."

# Task 1: Search image ubuntu on Dockerhub
check_command_executed "1. Search image ubuntu on Dockerhub" "docker search ubuntu" 100

# Task 2: Pull image ubuntu from Dockerhub
check_command_executed "2. Pull image ubuntu from Dockerhub" "docker pull ubuntu" 50
check_image_pulled "ubuntu" 50

# Task 3: Running ubuntu container and access to the console
check_command_executed "3. Running ubuntu container and access to the console" "docker run -it --name ubuntu1 ubuntu" 100

# Task 4: Run the ubuntu container and delete it when exiting
check_command_executed "4. Run ubuntu container with --rm and delete on exit" "docker run -it --rm --name ubuntu2 ubuntu" 100

# Tampilkan skor akhir
let total=$score\*100/$max_score
echo $score
echo "Nilai Anda:" $total

if [ $score -eq $max_score ]; then
    echo "All tasks completed successfully!"
else
    echo "Some tasks are not completed correctly."
fi

# Kirim hasil ke database MySQL
mysql_host="89.116.134.157"
mysql_user="rehan"
mysql_password="1234"
mysql_db="siswa"

docker exec -it nilaisql mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_db" -e "UPDATE siswa SET Docker_Lab_3 = '$total' WHERE id = '$student_id';"

# Verifikasi apakah query berhasil
if [ $? -eq 0 ]; then
    echo "Score updated successfully in the database."
else
    echo "Failed to update score in the database."
fi
