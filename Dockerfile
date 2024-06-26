# build env
FROM node:18-bookworm-slim as build

COPY ./frontend /frontend
WORKDIR /frontend
ENV NODE_OPTIONS --openssl-legacy-provider
RUN npm install && npm run build && rm -rf node_modules

# prod env
FROM python:3.9-slim-bookworm

RUN apt-get update \
  && apt-get install -y spamassassin supervisor libmagic-dev build-essential git curl iproute2 openssh-client openssh-server procps \
  && apt-get clean  \
  && rm -rf /var/lib/apt/lists/*

RUN sa-update

WORKDIR /backend

COPY pyproject.toml poetry.lock /backend/
COPY gunicorn.conf.py /backend
COPY app /backend/app
COPY startup.sh /backend

RUN pip install poetry==1.1.15 && poetry config virtualenvs.create false && poetry install --no-dev
RUN pip install circus

COPY circus.ini /etc/circus.ini

COPY --from=build /frontend /backend/frontend

# spamd envs
ENV SPAMD_MAX_CHILDREN=1 \
  SPAMD_PORT=7833 \
  SPAMD_RANGE="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.1/32"

# app envs
ENV SPAMASSASSIN_PORT=7833 \
  PORT=8000

EXPOSE $PORT

# CMD ["circusd", "/etc/circus.ini"]

RUN mkdir -p /app/.profile.d
COPY heroku-exec.sh /app/.profile.d

RUN git clone https://github.com/spamhaus/spamassassin-dqs
RUN chmod +x startup.sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh # Workaround for ps:exec
CMD bash -c "./startup.sh";circusd /etc/circus.ini
