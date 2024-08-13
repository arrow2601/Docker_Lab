#!/bin/bash

# Fungsi untuk memverifikasi apakah perintah yang diberikan sesuai dengan jawaban yang benar
docker load < /mysql.tar
docker run -d --name nilaisql -e MYSQL_ROOT_PASSWORD=1234 -p 3307:3306 mysql
check_command() {
    task_name=$1
    instruction=$2
    expected_command=$3
    verify_function=$4

    echo "$instruction"
    read -p "Masukkan perintah: " user_command

    if [ "$user_command" == "$expected_command" ]; then
        eval "$user_command" > output.log
        command_status=$?
        if [ $command_status -eq 0 ]; then
            $verify_function
            verify_status=$?
            if [ $verify_status -eq 0 ]; then
                echo -e "$task_name \e[32m✔\e[0m"
                return 1
            else
                echo -e "$task_name \e[31m✖\e[0m"
                return 0
            fi
        else
            echo -e "$task_name \e[31m✖\e[0m (command error)"
            return 0
        fi
    else
        echo -e "$task_name \e[31m✖\e[0m"
        return 0
    fi
}

# Fungsi untuk memverifikasi jika container redis1 sedang berjalan
verify_container_running() {
    if docker ps --format '{{.Names}}' | grep -q "redis1"; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk memverifikasi jika image nginx telah ter-pull
verify_docker_pull_nginx() {
    if docker images | grep -q "nginx"; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk memverifikasi jika container nginx1 atau nginx2 sedang berjalan
verify_container_running_nginx() {
    if docker ps --format '{{.Names}}' | grep -q "nginx1\|nginx2"; then
        return 0
    else
        return 1
    fi
}

# Meminta ID siswa
read -p "Masukkan ID siswa: " student_id

# Skor awal
score=0
max_score=1600  # Total skor untuk semua tugas

# Grading untuk Practice 1
echo "Grading Practice 1 tasks..."

# Task 1: Mencari docker image redis di docker hub
check_command "1. Mencari docker image redis di docker hub" "Masukkan perintah untuk mencari image redis di Docker Hub:" "docker search redis" "true"
score=$((score + $? * 100))

# Task 2: Menjalankan image Redis
check_command "2. Menjalankan image Redis" "Masukkan perintah untuk menjalankan image Redis:" "docker run -d --name redis1 redis" "verify_container_running"
score=$((score + $? * 100))

# Task 3: Menampilkan container yang berjalan
check_command "3. Menampilkan container yang berjalan" "Masukkan perintah untuk menampilkan container yang berjalan:" "docker ps" "true"
score=$((score + $? * 100))

# Task 4: Menampilkan semua container Docker
check_command "4. Menampilkan semua container Docker" "Masukkan perintah untuk menampilkan semua container Docker:" "docker ps -a" "true"
score=$((score + $? * 100))

# Task 5: Menampilkan deskripsi container
check_command "5. Menampilkan deskripsi container" "Masukkan perintah untuk menampilkan deskripsi container redis1:" "docker inspect redis1" "true"
score=$((score + $? * 100))

# Task 6: Menampilkan log container
check_command "6. Menampilkan log container" "Masukkan perintah untuk menampilkan log container redis1:" "docker logs redis1" "true"
score=$((score + $? * 100))

# Task 7: Menampilkan live stream resource yang digunakan container
check_command "7. Menampilkan live stream resource yang digunakan container" "Masukkan perintah untuk menampilkan live stream resource yang digunakan container redis1:" "docker stats redis1" "true"
score=$((score + $? * 100))

# Task 8: Menampilkan proses yang berjalan di container
check_command "8. Menampilkan proses yang berjalan di container" "Masukkan perintah untuk menampilkan proses yang berjalan di container redis1:" "docker top redis1" "true"
score=$((score + $? * 100))

# Task 9: Mematikan container
check_command "9. Mematikan container" "Masukkan perintah untuk mematikan container redis1:" "docker stop redis1" "true"
score=$((score + $? * 100))

# Grading untuk Practice 2
echo "Grading Practice 2 tasks..."

# Task 1: Mencari docker image nginx di docker hub
check_command "1. Mencari docker image nginx di docker hub" "Masukkan perintah untuk mencari image nginx di Docker Hub:" "docker search nginx" "true"
score=$((score + $? * 100))

# Task 2: Menjalankan image nginx dan expose ke port host
check_command "2. Menjalankan image nginx dan expose ke port host" "Masukkan perintah untuk menjalankan image nginx dan expose ke port host:" "docker run -d --name nginx1 -p 80:80 nginx" "verify_container_running_nginx"
score=$((score + $? * 100))

# Task 3: Menampilkan deskripsi container nginx1
check_command "3. Menampilkan deskripsi container nginx1" "Masukkan perintah untuk menampilkan deskripsi container nginx1:" "docker inspect nginx1" "true"
score=$((score + $? * 100))

# Task 4: Menjalankan image nginx dan mendeklarasikan port container
check_command "4. Menjalankan image nginx dan mendeklarasikan port container" "Masukkan perintah untuk menjalankan image nginx dan mendeklarasikan port container:" "docker run -d --name nginx2 -p 80 nginx" "verify_container_running_nginx"
score=$((score + $? * 100))

# Task 5: Test Browsing
check_command "5. Test Browsing" "Masukkan perintah untuk menjalankan test browsing ke nginx2:" "curl localhost:$(docker port nginx2 80 | cut -d : -f 2)" "true"
score=$((score + $? * 100))

# Task 6: Menampilkan container (semua)
check_command "6. Menampilkan container (semua)" "Masukkan perintah untuk menampilkan semua container:" "docker ps -a" "true"
score=$((score + $? * 100))

# Task 7: Menampilkan image docker
check_command "7. Menampilkan image docker" "Masukkan perintah untuk menampilkan image docker:" "docker images" "true"
score=$((score + $? * 100))

# Tampilkan skor akhir
let total=$score\*100/$max_score
echo $total

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

docker exec -it nilaisql mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_db" -e "UPDATE siswa SET Docker_Lab_2 = '$total' WHERE id = '$student_id';"

# Verifikasi apakah query berhasil
if [ $? -eq 0 ]; then
    echo "Score updated successfully in the database."
else
    echo "Failed to update score in the database."
fi
