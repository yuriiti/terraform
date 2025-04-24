#!/bin/bash
set -e

# Список сервисов (укажите нужные имена, они должны совпадать с именем каталога в ./services)
SERVICES=("send-to-s3-lambda")

# Параметры для ECR в LocalStack
ECR_HOST="localhost:4566"
AWS_ACCOUNT_ID="000000000000"
AWS_REGION="us-east-1"

for SERVICE in "${SERVICES[@]}"; do
    echo "Создаем (или проверяем) репозиторий ECR для ${SERVICE}..."
    docker exec awscli aws --endpoint-url="http://${ECR_HOST}" ecr create-repository --repository-name "${SERVICE}" 2>/dev/null || true

    echo "Собираем образ для ${SERVICE}..."
    docker build -t "${SERVICE}:latest" -f "services/${SERVICE}/Dockerfile" .

    echo "Тегируем образ ${SERVICE}:latest..."
    IMAGE_URI="${ECR_HOST}/${AWS_ACCOUNT_ID}/${SERVICE}:latest"
    docker tag "${SERVICE}:latest" "${IMAGE_URI}"

    echo "Пушим образ ${IMAGE_URI}..."
    docker push "${IMAGE_URI}"

    echo "Удаляем локальный образ ${SERVICE}:latest..."
    docker rmi "${SERVICE}:latest" || true

    echo "Удаляем локальный образ ${IMAGE_URI}..."
    docker rmi "${IMAGE_URI}" || true

    echo "Удаляем временный контейнер ${SERVICE}..."
    CONTAINER_ID=$(docker ps -q --filter "name=${SERVICE}")

    if [ -n "${CONTAINER_ID}" ]; then
        docker rm -f "${CONTAINER_ID}" || true
    fi

    echo "Удаляем временный образ ${SERVICE}..."
    IMAGE_ID=$(docker images -q "${SERVICE}:latest")

    if [ -n "${IMAGE_ID}" ]; then
        docker rmi "${IMAGE_ID}" || true
    fi

    echo "Готово для сервиса ${SERVICE}."
done

echo "Все сервисы успешно запушены в LocalStack ECR."
