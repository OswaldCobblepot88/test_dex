#!/bin/bash

REPO_URL="https://github.com/OswaldCobblepot88/test_dex.git"
PROJECT_DIR="test_dex"

if ! command -v git &> /dev/null; then
    exit 1
fi

if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR" || exit 1
    git pull origin main
else
    git clone "$REPO_URL"
    cd "$PROJECT_DIR" || exit 1
fi

if [ -f "package.json" ]; then
    if command -v pnpm &> /dev/null; then
        pnpm install
    elif command -v yarn &> /dev/null; then
        yarn install
    elif command -v npm &> /dev/null; then
        npm install
    fi
elif [ -f "requirements.txt" ] || [ -f "Pipfile" ] || [ -f "pyproject.toml" ]; then
    if command -v python3 &> /dev/null; then
        python3 -m venv venv
        source venv/bin/activate
        if [ -f "requirements.txt" ]; then
            pip install -r requirements.txt
        elif [ -f "Pipfile" ]; then
            pip install pipenv && pipenv install
        elif [ -f "pyproject.toml" ]; then
            pip install .
        fi
    fi
elif [ -f "Cargo.toml" ]; then
    if command -v cargo &> /dev/null; then
        cargo build
    fi
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    chmod +x gradlew 2>/dev/null
    if [ -f "gradlew" ]; then
        ./gradlew build
    fi
elif [ -f "go.mod" ]; then
    if command -v go &> /dev/null; then
        go mod download
    fi
fi

if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    cp .env.example .env
fi
