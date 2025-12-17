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

        // TAHAP 3: Smoke Tests & Prometheus check
        stage('Smoke Tests') {
            steps {
                echo 'Running smoke tests and Prometheus scrape checks...'
                sh '''
                  # Wait for backend /metrics to be available
                  for i in $(seq 1 12); do
                    status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/metrics || echo 000)
                    if [ "$status" -eq 200 ]; then
                      echo "Backend /metrics OK"
                      break
                    fi
                    echo "Waiting for /metrics ($i)..."
                    sleep 5
                  done

                  if [ "$status" -ne 200 ]; then
                    echo "ERROR: backend /metrics not reachable"; exit 1
                  fi

                  # Wait for Prometheus to scrape the metric
                  for i in $(seq 1 12); do
                    res=$(curl -s "http://localhost:9090/api/v1/query?query=http_requests_total" | grep -c '"http_requests_total"' || true)
                    if [ "$res" -gt 0 ]; then
                      echo "Prometheus scraping OK"
                      exit 0
                    fi
                    echo "Waiting for Prometheus scrape ($i)..."
                    sleep 5
                  done

                  echo "ERROR: Prometheus did not scrape backend metrics"; exit 1
                '''
            }
        }
    }
}
