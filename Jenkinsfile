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

        // TAHAP 2: Build & Deploy (safe, app-only)
        stage('Build & Deploy') {
            steps {
                echo '🚀 Starting Safe Deployment (build only app services)...'
                sh '''
                  # Remove only app containers (ignore errors)
                  docker rm -f sinfomik_backend || true
                  docker rm -f sinfomik_frontend || true

                  # Detect docker-compose command (docker-compose or 'docker compose')
                  if command -v docker-compose >/dev/null 2>&1; then
                    DC=docker-compose
                  elif docker compose version >/dev/null 2>&1; then
                    DC="docker compose"
                  else
                    echo "ERROR: neither 'docker-compose' nor 'docker compose' is available on this agent"; exit 1
                  fi

                  echo "Using compose command: $DC"

                  # Build backend & frontend images (no-cache on first try)
                  eval "$DC -f ${COMPOSE_FILE} build --no-cache backend frontend" || eval "$DC -f ${COMPOSE_FILE} build backend frontend"

                  # Deploy only the app services; do NOT touch prometheus/grafana
                  eval "$DC -f ${COMPOSE_FILE} up -d --build backend frontend"
                '''
            }
        }


    }
}
