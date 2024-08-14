#!/bin/bash
docker load < /mysql.tar
docker run -d --name nilaisql -e MYSQL_ROOT_PASSWORD=1234 -p 3307:3306 mysql
# Fungsi untuk memverifikasi jika container tertentu berjalan
verify_container_running() {
    container_name=$1
    if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk memverifikasi jika image tertentu telah ter-pull
verify_image_pulled() {
    image_name=$1
    if docker images | grep -q "$image_name"; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk memverifikasi apakah container telah dihapus
verify_container_removed() {
    container_name=$1
    if ! docker ps -a --format '{{.Names}}' | grep -q "$container_name"; then
        return 0
    else
        return 1
    fi
}

verify_container_stopped() {
    container_name=$1
    if ! docker ps  --format '{{.Names}}' | grep -q "$container_name"; then
        return 0
    else
        return 1
    fi
}

# Meminta ID siswa
read -p "Masukkan ID siswa: " student_id

# Skor awal
score=0
max_score=800  # Total skor untuk semua tugas

# Grading untuk Docker Practice 1

echo "Grading Docker tasks..."

# Task 1: Verifikasi apakah perintah 'docker search redis' telah dijalankan
if grep -q "docker search redis" ~/.ash_history; then
    score=$((score + 100))
else
    echo "Task 1: Perintah 'docker search redis' belum dijalankan"
fi

# Task 2: Verifikasi apakah image redis telah di-pull dan container redis1 berjalan
if verify_image_pulled "redis"; then
    score=$((score + 100))
else
    echo "Task 2: Image redis belum di-pull atau container redis1 tidak berjalan"
fi

# Task 3: Verifikasi apakah perintah 'docker ps' telah dijalankan
if grep -q "docker ps" ~/.ash_history; then
    score=$((score + 100))
else
    echo "Task 3: Perintah 'docker ps' belum dijalankan"
fi

# Task 4: Verifikasi apakah container redis1 telah distop
if verify_container_stopped "redis1"; then
    score=$((score + 100))
else
    echo "Task 4: Container redis1 belum dihapus"
fi

# Grading untuk Docker Practice 2

# Task 5: Verifikasi apakah perintah 'docker search nginx' telah dijalankan
if grep -q "docker search nginx" ~/.ash_history; then
    score=$((score + 100))
else
    echo "Task 5: Perintah 'docker search nginx' belum dijalankan"
fi

# Task 6: Verifikasi apakah image nginx telah di-pull dan container nginx1 berjalan
if verify_image_pulled "nginx" && verify_container_running "nginx1"; then
    score=$((score + 100))
else
    echo "Task 6: Image nginx belum di-pull atau container nginx1 tidak berjalan"
fi

# Task 7: Verifikasi apakah perintah 'docker ps -a' telah dijalankan
if grep -q "docker ps -a" ~/.ash_history; then
    score=$((score + 100))
else
    echo "Task 7: Perintah 'docker ps -a' belum dijalankan"
fi

# Task 8: Verifikasi apakah container nginx1 dan nginx2 telah berjalan dan dites browsing
if verify_container_running "nginx2" && grep -q "curl localhost" ~/.ash_history; then
    score=$((score + 100))
else
    echo "Task 8: Container nginx2 tidak berjalan atau test browsing belum dilakukan"
fi

# Tampilkan skor akhir
let total=$score\*100/$max_score
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

docker exec -it nilaisql mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_db" -e "UPDATE siswa SET Docker_Lab_2 = '$total' WHERE id = '$student_id';"
# Verifikasi apakah query berhasil
if [ $? -eq 0 ]; then
    echo "Score updated successfully in the database."
else
    echo "Failed to update score in the database."
fi
