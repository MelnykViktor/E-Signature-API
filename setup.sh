#!/bin/bash

# Exit on error
set -e

# Define variables
ENV_FILE=".env"
ENV_EXAMPLE_FILE=".env.example"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# Functions
function check_dependency {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "I require $1 but it's not installed. Aborting."; exit 1; }
}

function generate_env_file {
    if [ ! -f "$ENV_FILE" ]; then
        echo "Copying .env.example to .env"
        cp $ENV_EXAMPLE_FILE $ENV_FILE
    else
        echo ".env file already exists. Skipping..."
    fi
}

function start_docker {
    echo "Starting Docker containers..."
    docker compose up -d
}

function composer_install {
    echo "Installing Composer dependencies..."
    docker compose exec -it app composer install
}

function generate_app_key {
    echo "Generating application key..."
    docker compose exec -it app php artisan key:generate
}

function run_migrations {
    echo "Running migrations..."
    docker compose exec -it app php artisan migrate
}

function setup_project {
    # Check for required dependencies
    check_dependency docker
    check_dependency docker compose
    check_dependency git

    # Generate .env file
    generate_env_file

    # Start Docker containers
    start_docker

    # Install Composer dependencies
    composer_install

    # Generate application key
    generate_app_key

    # Run migrations
    run_migrations

    echo "Project setup completed successfully!"
}

# Run the setup function
setup_project
