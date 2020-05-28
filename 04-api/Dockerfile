FROM python:3.8.2-slim

WORKDIR /api
COPY . /api

RUN apt-get update -y \
    && apt-get install -y gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install -r requirements.txt --no-cache-dir

CMD gunicorn main:api -c gunicorn_config.py
