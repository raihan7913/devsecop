pipeline {
    agent any

    environment {
        // Mendefinisikan Environment Variables
        COMPOSE_FILE = 'docker-compose.yml'
    }

    stages {
        // TAHAP 1: Ambil Kode dari GitHub
        stage('Checkout Code') {
            steps {
                // Perintah ini otomatis mengambil kode dari repo yang disetting di Job
                checkout scm
            }
        }

        // TAHAP 2: Build & Deploy (The Real Deal)
        stage('Build & Deploy') {
            steps {
                echo '🚀 Starting Real Deployment...'
                
                // Matikan container lama & Build ulang yang baru
                // Kita pakai perintah shell 'sh' sungguhan
                sh 'docker-compose down'
                sh 'docker-compose up -d --build'
            }
        }
        
        // TAHAP 3: Verify
        stage('Health Check') {
            steps {
                echo 'Checking if services are up...'
                // Tunggu 10 detik biar server nyala dulu
                sleep 10 
                // Cek status container
                sh 'docker-compose ps'
            }
        }
    }
}
