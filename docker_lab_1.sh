#!/bin/bash

# Fungsi untuk memverifikasi apakah perintah yang diberikan sesuai dengan jawaban yang benar
docker load < /mysql.tar
docker run -d --name my-mysql -e MYSQL_ROOT_PASSWORD=1234 -p 3306:3306 mysql
check_command() {
    task_name=$1
    instruction=$2
    expected_command=$3
    verify_function=$4

    echo "$instruction"
    read -p "Masukkan perintah: " user_command

    if [ "$user_command" == "$expected_command" ]; then
        eval "$user_command" | tee output.log
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

# Fungsi untuk memeriksa apakah image nginx telah ter-pull
verify_docker_pull_nginx() {
    if docker images | grep -q "nginx"; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk memeriksa apakah image nginx telah terhapus
verify_docker_rm_nginx() {
    if ! docker images | grep -q "nginx"; then
        return 0
    else
        return 1
    fi
}

# Meminta ID siswa
read -p "Masukkan ID siswa: " student_id

# Skor awal
score=0
max_score=400  # Total skor untuk semua tugas

# Grading untuk tugas
echo "Grading tasks..."

# Task 1: Mencari docker image nginx di docker hub
check_command "1. Mencari docker image nginx di docker hub" "Masukkan perintah untuk mencari image nginx di Docker Hub:" "docker search nginx" "true"
score=$((score + $? * 100))

# Task 2: Download docker image nginx dari docker hub
check_command "2. Download docker image nginx dari docker hub" "Masukkan perintah untuk mendownload image nginx dari Docker Hub:" "docker pull nginx" "verify_docker_pull_nginx"
score=$((score + $? * 100))

# Task 3: Melihat list docker image
check_command "3. Melihat list docker image" "Masukkan perintah untuk melihat list docker images:" "docker images" "true"
score=$((score + $? * 100))

# Task 4: Menghapus image nginx yang tadi sudah didownload
check_command "4. Menghapus image nginx yang tadi sudah didownload" "Masukkan perintah untuk menghapus image nginx yang telah didownload:" "docker image rm nginx" "true"
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

# Menggunakan mysql -u dengan path lengkap jika perlu
docker exec -it my-mysql mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_db" -e "UPDATE siswa SET Docker_Lab_1 = '$total' WHERE id = '$student_id';"

if [ $? -eq 0 ]; then
    echo "Score updated successfully in the database."
else
    echo "Failed to update score in the database."
fi
