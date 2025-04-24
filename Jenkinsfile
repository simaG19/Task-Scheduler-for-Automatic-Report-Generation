pipeline {
    agent any

    tools {
        php 'php8.2'               
        composer 'global-composer' 
    }

    environment {
        // Override .env values for testing:
        DB_CONNECTION = 'sqlite'
        DB_DATABASE   = "${WORKSPACE}/database/testing.sqlite"
    }

    options {
        // keep only the last 10 builds’ data to save disk
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // timestamps in console output
        timestamps()
        // fail the build if any `sh` step returns non-zero
        ansiColor('xterm')
    }

    stages {
        stage('Checkout') {
            steps {
                // clone the repo
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    composer install --no-interaction --prefer-dist --optimize-autoloader
                '''
            }
        }

        stage('Prepare .env & Key') {
            steps {
                sh '''
                    if [ -f .env.example ]; then
                      cp .env.example .env
                    else
                      echo "⛔ .env.example not found" && exit 1
                    fi

                    php artisan key:generate --ansi --no-interaction
                '''
            }
        }

        stage('Configure SQLite') {
            steps {
                sh '''
                    mkdir -p database
                    # create (or reset) the SQLite file
                    rm -f database/testing.sqlite
                    touch database/testing.sqlite
                '''
            }
        }

        stage('Migrate Database') {
            steps {
                sh 'php artisan migrate --force'
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    if [ -f vendor/bin/pest ]; then
                      vendor/bin/pest --no-interaction --coverage --coverage-junit=tests/logs/junit.xml
                    else
                      vendor/bin/phpunit --colors=always --log-junit tests/logs/junit.xml
                    fi
                '''
            }
        }

        stage('Publish Results') {
            steps {
                // collect JUnit-style XML so Jenkins can show test results
                junit 'tests/logs/junit.xml'
                // archive logs or any built assets
                archiveArtifacts artifacts: 'storage/logs/*.log', fingerprint: true
            }
        }
    }

    post {
        success {
            echo "✅ Build successful!"
        }
        failure {
            echo "❌ Build failed — check the console output and JUnit report."
        }
        always {
            // clean workspace to avoid stale files
            cleanWs()
        }
    }
}
