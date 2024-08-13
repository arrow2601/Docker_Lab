#!/bin/bash

# Fungsi untuk memulai Lab I dengan Docker container dasar
start_lab_1() {
    echo "Starting Lab"
    docker run -dit --name dockerlab --privileged rehan26/dockerlab:v3
    docker exec -it dockerlab git clone https://github.com/arrow2601/Docker_Lab.git
    docker exec dockerlab mv Docker_Lab/docker_lab_1.sh /usr/local/bin/docker-lab-1-start
    docker exec dockerlab chmod +x /usr/local/bin/docker-lab-1-start
    docker exec dockerlab mv Docker_Lab/docker_lab_2.sh /usr/local/bin/docker-lab-2-start
    docker exec dockerlab chmod +x /usr/local/bin/docker-lab-2-start
    docker exec dockerlab mv Docker_Lab/docker_lab_3.sh /usr/local/bin/docker-lab-3-start
    docker exec dockerlab chmod +x /usr/local/bin/docker-lab-3-start
    docker exec -it dockerlab /bin/sh
    echo "Lab I environment started with container name lab1_env"
}
# Memulai lab berdasarkan argumen yang diberikan
start_lab_1
bash dockerlab_finish.sh
