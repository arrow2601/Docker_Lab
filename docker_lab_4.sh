#!/bin/bash

# Fungsi untuk memverifikasi apakah perintah yang diberikan sesuai dengan jawaban yang benar
  # Memuat dan menjalankan MySQL container
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

# Fungsi untuk memverifikasi container MySQL berjalan
verify_mysql_running() {
    if docker ps --format '{{.Names}}' | grep -q "my-mysql"; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk memverifikasi image phpMyAdmin telah ter-pull
verify_phpmyadmin_pulled() {
    if docker images | grep -q "phpmyadmin"; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk memverifikasi container phpMyAdmin berjalan
verify_phpmyadmin_running() {
    if docker ps --format '{{.Names}}' | grep -q "my-phpmyadmin"; then
        return 0
    else
        return 1
    fi
}

# Meminta ID siswa
read -p "Masukkan ID siswa: " student_id

# Skor awal
score=0
max_score=1800  # Total skor untuk semua tugas

# Grading untuk Practice I
echo "Grading Practice I tasks..."

# Task 1: Menjalankan container MySQL dengan parameter tambahan (env)
check_command "1. Menjalankan container MySQL dengan parameter tambahan (env)" "Menjalankan container MySQL dengan parameter tambahan (env):" "docker run -d --name my-mysql -e MYSQL_ROOT_PASSWORD=latihan05 -p 3306:3306 mysql" "verify_mysql_running"
score=$((score + $? * 100))

# Task 2: Pull image phpMyAdmin dari DockerHub
check_command "2. Pull image phpMyAdmin dari DockerHub" "Pull image phpMyAdmin dari DockerHub:" "docker pull phpmyadmin" "verify_phpmyadmin_pulled"
score=$((score + $? * 100))

# Task 3: Menjalankan container phpMyAdmin dan hubungkan dengan container MySQL
check_command "3. Menjalankan container phpMyAdmin dan hubungkan dengan container MySQL" "Menjalankan container phpMyAdmin dan hubungkan dengan container MySQL:" "docker run --name my-phpmyadmin -d --link my-mysql:db -p 8090:80 phpmyadmin" "verify_phpmyadmin_running"
score=$((score + $? * 100))

# Task 4: Test Browsing
echo "4. Test Browsing"
echo "Buka browser dan akses http://your_ip_address:8090, login dengan user: root dan password: latihan05."
echo -e "4. Test Browsing \e[32m✔\e[0m"
score=$((score + 100))

# Grading untuk Practice II
echo "Grading Practice II tasks..."

# Task 1: Menjalankan container Ubuntu dengan nama ubuntu1 dan ubuntu2
check_command "1. Menjalankan container Ubuntu dengan nama ubuntu1 dan ubuntu2" "Menjalankan container Ubuntu dengan nama ubuntu1 dan ubuntu2:" "docker run -dit --name ubuntu1 ubuntu && docker run -dit --name ubuntu2 ubuntu" "true"
score=$((score + $? * 100))

# Task 2: Menampilkan daftar container
check_command "2. Menampilkan daftar container" "Menampilkan daftar container:" "docker ps" "true"
score=$((score + $? * 100))

# Task 3: Pause container ubuntu1 dan ubuntu2
check_command "3. Pause container ubuntu1 dan ubuntu2" "Pause container ubuntu1 dan ubuntu2:" "docker pause ubuntu1 && docker pause ubuntu2" "true"
score=$((score + $? * 100))

# Task 4: Cek status container yang di-pause
check_command "4. Cek status container yang di-pause" "Cek status container yang di-pause:" "docker ps" "true"
score=$((score + $? * 100))

# Task 5: Cek penggunaan resource ketika container ubuntu di-pause
check_command "5. Cek penggunaan resource ketika container ubuntu di-pause" "Cek penggunaan resource ketika container ubuntu di-pause:" "docker stats ubuntu1 && docker stats ubuntu2" "true"
score=$((score + $? * 100))

# Task 6: Unpause container ubuntu1
check_command "6. Unpause container ubuntu1" "Unpause container ubuntu1:" "docker unpause ubuntu1" "true"
score=$((score + $? * 100))

# Grading untuk Practice III
echo "Grading Practice III tasks..."

# Task 1: Buat container database dengan spesifikasi terbatas
check_command "1. Buat container database dengan spesifikasi terbatas" "Buat container database dengan spesifikasi terbatas:" "docker container run -d --name ch6_mariadb --memory 256m --cpu-shares 1024 --cap-drop net_raw -e MYSQL_ROOT_PASSWORD=test mariadb:5.5" "true"
score=$((score + $? * 100))

# Task 2: Buat container WordPress dan hubungkan ke database container
check_command "2. Buat container WordPress dan hubungkan ke database container" "Buat container WordPress dan hubungkan ke database container:" "docker container run -d -p 80:80 -P --name ch6_wordpress --memory 512m --cpu-shares 512 --cap-drop net_raw --link ch6_mariadb:mysql -e WORDPRESS_DB_PASSWORD=test wordpress:5.0.0-php7.2-apache" "true"
score=$((score + $? * 100))

# Task 3: Cek log, proses berjalan, dan resource
check_command "3. Cek log, proses berjalan, dan resource" "Cek log, proses berjalan, dan resource:" "docker logs ch6_mariadb && docker logs ch6_wordpress && docker top ch6_wordpress && docker top ch6_mariadb && docker stats ch6_mariadb && docker stats ch6_wordpress" "true"
score=$((score + $? * 100))

# Task 4: Test Browsing
echo "4. Test Browsing"
echo "Buka browser dan akses http://your_ip_address lalu selesaikan instalasi."
echo -e "4. Test Browsing \e[32m✔\e[0m"
score=$((score + 100))

# Tampilkan skor akhir
let total=$score\*100/$max_score
echo $total

if [ $score -eq $max_score ]; then
    echo "All tasks completed successfully!"
else
    echo "Some tasks are not completed correctly."
fi

# Kirim hasil ke database MySQL
mysql_host="187.116.134.157"
mysql_user="rehan"
mysql_password="1234"
mysql_db="siswa"
mysql_port="3307"

docker exec -it nilaisql mysql -h "$mysql_host" -P "$mysql_port" -u "$mysql_user" -p"$mysql_password" "$mysql_db" -e "UPDATE siswa SET Docker_Lab_4 = '$total' WHERE id = '$student_id';"

# Verifikasi apakah query berhasil
if [ $? -eq 0 ]; then
    echo "Score updated successfully in the database."
else
    echo "Failed to update score in the database."
fi
