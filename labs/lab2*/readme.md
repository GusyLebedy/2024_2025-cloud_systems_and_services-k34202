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
2. Использование локальных путей для хранения данных без `volumes`
3. Раскрытие ненужных портов.
### Напишем "хороший" Dockerfile, в котором эти плохие практики исправлены.
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
Что стало лучше:



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

### Не хочется потерять эти материалы по теме:
https://dotsandbrackets.com/persistent-data-docker-volumes-ru/
https://slurm.io/blog/tpost/i5ikrm9fj1-hranenie-dannih-v-docker
https://habr.com/ru/articles/804331/
https://habr.com/ru/articles/310460/

