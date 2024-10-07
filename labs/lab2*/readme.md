# Лабораторная №2*

## Задание (со звёздочкой)

1. Написать “плохой” Docker compose файл, в котором есть не менее трех “bad practices” по их написанию.
2. Написать “хороший” Docker compose файл, в котором эти плохие практики исправлены.
3. В Readme описать каждую из плохих практик в плохом файле, почему она плохая и как в хорошем она была исправлена, как исправление повлияло на результат.
4. После предыдущих пунктов в хорошем файле настроить сервисы так, чтобы контейнеры в рамках этого compose-проекта так же поднимались вместе, но не "видели" друг друга по сети. В отчете описать, как этого добились и кратко объяснить принцип такой изоляции.



## Ход работы
### Напишем “плохой” Docker compose файл, в котором есть не менее трех “bad practices” по их написанию.

```
version: '3'
services:
  web:
    image: python:latest 
    ports:
      - "5000:5000"
    depends_on:
      - db
  db:
    image: postgres
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydatabase
    volumes:
      - /var/lib/postgresql/data 
  cache:
    image: redis
    ports:
      - "6379:6379" 
```
Рассмотрим каждую ошибку по отдельности:
1. Использование тега `latest` (аналогично обычному докерфайлу) делает сборку непредсказуемой. Т.к. `latest` - не что-то постоянное, а каждая новая версия образа может сломать совместимость приложения.
2. Использование локальных путей для хранения данных без `volumes`. Когда Docker контейнер перезапускается, все его данные, которые не хранятся в volume очищаются. Для того, чтобы сохранить важные данные, например, состояние базы данных из контейнера, необходимо создать volume, который будет хранить эти данные на хосте, на котором работает контейнер. В данном файле мы храним только локальный файл БД, сама БД остаётся незащищённой.
3. Раскрытие ненужных портов. Открытие всех портов может привести к рискам безопасности, особенно если сервисы не должны быть доступны извне. В данном случае Redis не должен быть доступен извне, так как он используется только внутри сети контейнеров.
### Напишем “хороший” Docker compose файл, в котором эти плохие практики исправлены.
```
version: '3'
services:
  web:
    image: python:3.9
    ports:
      - "5000:5000"
    depends_on:
      - db
    networks:
      - isolated_network

  db:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydatabase
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - isolated_network

  cache:
    image: redis:6
    networks:
      - isolated_network

volumes:
  db_data:

networks:
  isolated_network:
    driver: bridge
```
1. Используем тега `latest`, сохраняя версию.

<b>Результат:</b> процесс сборки стал более стабильным и воспроизводимым.

2. Используем `volumes` не только для локального файлф в БД, но и храним её полностью.
   
<b>Результат:</b> упростилось управление данными и повысилась переносимость между различными системами.

3. Открываем только необходимые порты.

<b>Результат:</b> повысилась безопасность, т.к. мы не "светим" ненужные порты во внешней сети.

### Изоляция

```
version: '3'
services:
  web:
    image: python:3.9
    ports:
      - "5000:5000"
    depends_on:
      - db
    networks:
      - web_network

  db:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydatabase
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - db_network

  cache:
    image: redis:6
    networks:
      - cache_network

volumes:
  db_data:

networks:
  web_network:
    driver: bridge
  db_network:
    driver: bridge
  cache_network:
    driver: bridge
```
Чтобы контейнеры не видели друг друга, но поднимались вместе, будем использовать отдельные сети для каждого сервиса. В нашем примере для каждого сервиса создана отдельная сеть (web_network, db_network, cache_network) -> контейнеры не могут взаимодействовать между собой, т.к. находятся в изолированных сетях. При этом они поднимаются одновременно, но не имеют сетевого доступа друг к другу.

Принцип изоляции: В Docker сети создаются с использованием технологии "bridge". Каждый контейнер может видеть только те контейнеры, которые подключены к той же сети. Создавая разные сети, мы физически изолируем контейнеры друг от друга по сети.

### Не хочется потерять эти материалы по теме:
[Как хранить данные в Docker volumes](https://dotsandbrackets.com/persistent-data-docker-volumes-ru/)

[Хранение данных в Docker](https://slurm.io/blog/tpost/i5ikrm9fj1-hranenie-dannih-v-docker)

[Docker для новичков — #3 Что нужно знать о Docker compose](https://habr.com/ru/articles/804331/)

[Полное практическое руководство по Docker: с нуля до кластера на AWS](https://habr.com/ru/articles/310460/)

