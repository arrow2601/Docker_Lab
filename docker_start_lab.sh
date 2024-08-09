#!/bin/bash

# Fungsi untuk memulai Lab I dengan Docker container dasar
start_lab_1() {
    echo "Starting Lab"
    docker run -dit --name --privileged dockerlab rehan26/dockerlab
    docker exec -it dockerlab /bin/sh
    echo "Lab I environment started with container name lab1_env"
}
# Memulai lab berdasarkan argumen yang diberikan
start_lab_1
