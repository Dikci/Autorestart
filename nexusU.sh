#!/bin/bash

# Загружаем переменные из /etc/environment
export $(grep -v '^#' /etc/environment | xargs)

# Загружаем bashrc
source /root/.bashrc

# Запускаем nexus-network с абсолютным путём
/root/.nexus/bin/nexus-network start --node-id $ID

# Оставляем сессию открытой после завершения
exec bash
