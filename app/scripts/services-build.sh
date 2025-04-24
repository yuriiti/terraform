#!/bin/bash
set -e

# Массив со списком сервисов (укажите необходимые сервисы)
SERVICES=("send-to-s3-lambda")
TEMP_DIR="services-builded"

# Функция для сборки образа, создания контейнера и копирования папки
build_and_extract() {
    SERVICE_NAME="$1"
    ARCHIVE_NAME="${SERVICE_NAME}.zip"
    DOCKERFILE_PATH="services/${SERVICE_NAME}/Dockerfile"
    IMAGE_TAG="${SERVICE_NAME}-image"
    # Папка внутри контейнера, которую необходимо скопировать
    CONTAINER_FOLDER="/var/task/dist/services/${SERVICE_NAME}"
    # Локальная папка для сохранения извлечённого содержимого
    HOST_FOLDER="./${TEMP_DIR}/${SERVICE_NAME}"

    echo "Собираем образ для ${SERVICE_NAME}..."
    docker build -t "${IMAGE_TAG}" -f "${DOCKERFILE_PATH}" .

    echo "Создаём временный контейнер для ${SERVICE_NAME}..."
    CONTAINER_ID=$(docker create "${IMAGE_TAG}")
    echo "Извлекаем папку ${CONTAINER_FOLDER} из контейнера ${CONTAINER_ID} в ${HOST_FOLDER}..."
    mkdir -p "${HOST_FOLDER}"
    docker cp "${CONTAINER_ID}:${CONTAINER_FOLDER}/." "${HOST_FOLDER}"

    echo "Удаляем временный контейнер ${CONTAINER_ID}..."
    docker rm "${CONTAINER_ID}"

    echo "Запаковываем только содержимое папки ${HOST_FOLDER} в архив ${ARCHIVE_NAME}..."
    (cd "${HOST_FOLDER}" && zip -r "../../${ARCHIVE_NAME}" .)

    echo "Удаляем временную папку ${HOST_FOLDER}..."
    rm -rf "${HOST_FOLDER}"

    echo "Перемещаем архив ${ARCHIVE_NAME} в папку services/${SERVICE_NAME}/..."
    mkdir -p "services/${SERVICE_NAME}"
    mv "${ARCHIVE_NAME}" "services/${SERVICE_NAME}/"

    echo "Готово для сервиса ${SERVICE_NAME}."
}

for SERVICE in "${SERVICES[@]}"; do
    build_and_extract "${SERVICE}"
done

rm -rf "${TEMP_DIR}"
