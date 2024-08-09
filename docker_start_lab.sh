#!/bin/bash

# Fungsi untuk memulai Lab I dengan Docker container dasar
start_lab_1() {
    echo "Starting Lab"
    docker run -dit --name dockerlab --privileged rehan26/dockerlab:v3
    docker exec -it git clone https://github.com/arrow2601/Docker_Lab.git
    docker exec -it dockerlab /bin/sh
    echo "Lab I environment started with container name lab1_env"
}
# Memulai lab berdasarkan argumen yang diberikan
start_lab_1
