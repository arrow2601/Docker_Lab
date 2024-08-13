#!/bin/bash

# Memuat dan menjalankan MySQL container
docker load < /mysql.tar
docker run -d --name nilaisql -e MYSQL_ROOT_PASSWORD=1234 -p 3306:3306 mysql

# Fungsi untuk memverifikasi apakah perintah yang diberikan sesuai dengan jawaban yang benar
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

# Fungsi untuk memverifikasi jika container sedang berjalan
verify_container_running() {
    container_name=$1
    if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk memverifikasi jika image telah ter-pull
verify_docker_pull() {
    image_name=$1
    if docker images | grep -q "$image_name"; then
        return 0
    else
        return 1
    fi
}

# Meminta ID siswa
read -p "Masukkan ID siswa: " student_id

# Skor awal
score=0
max_score=2100  # Total skor untuk semua tugas Practice I dan II

# Grading untuk Practice I
echo "Grading Practice I tasks..."

# Task 1: Mencari docker image nginx
check_command "1. Mencari docker image nginx" "Mencari docker image nginx" "docker search nginx" "true"
score=$((score + $? * 100))

# Task 2: Menjalankan image nginx dengan nama nginx1 dan expose ke port 8080
check_command "2. Menjalankan image nginx dengan nama nginx1 dan expose ke port 8080" "Menjalankan image nginx dengan nama nginx1 dan expose ke port 8080" "docker run -d --name nginx1 -p 8080:80 nginx" "verify_container_running nginx1"
score=$((score + $? * 100))

# Task 3: Menampilkan deskripsi container nginx1
check_command "3. Menampilkan deskripsi container nginx1" "Menampilkan deskripsi container nginx1" "docker inspect nginx1" "true"
score=$((score + $? * 100))

# Task 4: Menjalankan image nginx dengan nama nginx2 dan expose ke port 8081
check_command "4. Menjalankan image nginx dengan nama nginx2 dan expose ke port 8081" "Menjalankan image nginx dengan nama nginx2 dan expose ke port 8081" "docker run -d --name nginx2 -p 8081:80 nginx" "verify_container_running nginx2"
score=$((score + $? * 100))

# Task 5: Menampilkan semua container
check_command "5. Menampilkan semua container" "Menampilkan semua container" "docker ps -a" "true"
score=$((score + $? * 100))

# Task 6: Mengecek output nginx pada container
check_command "6. Mengecek output nginx pada container" "Mengecek output nginx pada container nginx1 dan nginx2" "curl localhost:8080 && curl localhost:8081" "true"
score=$((score + $? * 100))

# Task 7: Mengakses container nginx2
check_command "7. Mengakses container nginx2" "Mengakses container nginx2" "docker exec -it nginx2 /bin/bash" "true"
score=$((score + $? * 100))

# Task 8: Update dan install editor di container nginx2
check_command "8. Update dan install editor di container nginx2" "Update dan install editor di container nginx2" "apt-get update -y && apt-get install nano -y" "true"
score=$((score + $? * 100))

# Task 9: Mengedit index.html dan memindahkan ke direktori default nginx
check_command "9. Mengedit index.html dan memindahkan ke direktori default nginx" "Mengedit index.html dan memindahkan ke direktori default nginx" "echo '<html><body>MR. DIY</body></html>' > index.html && mv index.html /usr/share/nginx/html" "true"
score=$((score + $? * 100))

# Task 10: Merestart service nginx di container
check_command "10. Merestart service nginx di container" "Merestart service nginx di container" "service nginx restart" "true"
score=$((score + $? * 100))

# Task 11: Menjalankan ulang container nginx2
check_command "11. Menjalankan ulang container nginx2" "Menjalankan ulang container nginx2" "docker start nginx2" "verify_container_running nginx2"
score=$((score + $? * 100))

# Task 12: Menampilkan deskripsi container nginx1 dan nginx2
check_command "12. Menampilkan deskripsi container nginx1 dan nginx2" "Menampilkan deskripsi container nginx1 dan nginx2" "docker inspect nginx1 && docker inspect nginx2" "true"
score=$((score + $? * 100))

# Task 13: Mengecek output nginx pada container setelah restart
check_command "13. Mengecek output nginx pada container setelah restart" "Mengecek output nginx pada container setelah restart" "curl localhost:8080 && curl localhost:8081" "true"
score=$((score + $? * 100))

# Task 14: Menampilkan log container nginx1 dan nginx2
check_command "14. Menampilkan log container nginx1 dan nginx2" "Menampilkan log container nginx1 dan nginx2" "docker logs nginx1 && docker logs nginx2" "true"
score=$((score + $? * 100))

# Task 15: Menampilkan deskripsi container nginx1 dan nginx2 (ulang)
check_command "15. Menampilkan deskripsi container nginx1 dan nginx2 (ulang)" "Menampilkan deskripsi container nginx1 dan nginx2 (ulang)" "docker inspect nginx1 && docker inspect nginx2" "true"
score=$((score + $? * 100))

# Task 16: Menampilkan live resources yang digunakan oleh container nginx1 dan nginx2
check_command "16. Menampilkan live resources yang digunakan oleh container nginx1 dan nginx2" "Menampilkan live resources yang digunakan oleh container nginx1 dan nginx2" "docker stats nginx1 && docker stats nginx2" "true"
score=$((score + $? * 100))

# Task 17: Menampilkan proses yang berjalan di container nginx1 dan nginx2
check_command "17. Menampilkan proses yang berjalan di container nginx1 dan nginx2" "Menampilkan proses yang berjalan di container nginx1 dan nginx2" "docker top nginx1 && docker top nginx2" "true"
score=$((score + $? * 100))

# Grading untuk Practice II
echo "Grading Practice II tasks..."

# Task 1: Mencari docker image ubuntu di docker hub
check_command "1. Mencari docker image ubuntu di docker hub" "Mencari docker image ubuntu di docker hub" "docker search ubuntu" "true"
score=$((score + $? * 100))

# Task 2: Menarik image ubuntu dari docker hub
check_command "2. Menarik image ubuntu dari docker hub" "Menarik image ubuntu dari docker hub" "docker pull ubuntu" "verify_docker_pull ubuntu"
score=$((score + $? * 100))

# Task 3: Menjalankan container ubuntu dan akses ke konsol
check_command "3. Menjalankan container ubuntu dan akses ke konsol" "Menjalankan container ubuntu dan akses ke konsol" "docker run -it ubuntu" "true"
score=$((score + $? * 100))

# Task 4: Menjalankan container ubuntu dan menghapusnya setelah keluar
check_command "4. Menjalankan container ubuntu dan menghapusnya setelah keluar" "Menjalankan container ubuntu dan menghapusnya setelah keluar" "docker run -it --rm --name ubuntu2 ubuntu" "true"
score=$((score + $? * 100))

# Tampilkan skor akhir
let total=$score\*100/$max_score
echo "Skor akhir: $total"

if [ $score -eq $max_score ]; then
    echo "Semua tugas berhasil diselesaikan dengan benar!"
else
    echo "Beberapa tugas belum diselesaikan dengan benar."
fi

# Kirim hasil ke database MySQL
mysql_host="89.116.134.157"
mysql_user="rehan"
mysql_password="1234"
mysql_db="siswa"

docker exec -it nilaisql mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_db" -e "UPDATE siswa SET Docker_Lab_2 = '$total' WHERE id = '$student_id';"


echo "Hasil telah disimpan ke database."
