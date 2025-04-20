#!/bin/bash
set -e

cd "$(dirname "$0")/.." || exit 1

# Собираем образ из Dockerfile, расположенного в папке tests
docker build -t test-runner -f "$(pwd)/tests/Dockerfile" .

# Запускаем контейнер с именем test-runner, подключаем его к сети localstack_network,
# передаём переменные окружения из .env.local и монтируем папку tests в /app/tests в контейнере.
docker run --rm \
    --network terraform_localstack_network \
    --env-file .env.local \
    -v "$(pwd)/tests:/app/tests:delegated" \
    --name test-runner \
    test-runner
