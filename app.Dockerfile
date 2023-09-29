# build env
FROM node:18-buster-slim as build

COPY ./frontend /frontend
WORKDIR /frontend
ENV NODE_OPTIONS --openssl-legacy-provider
RUN npm install && npm run build && rm -rf node_modules

# prod env
FROM python:3.9-slim-buster

RUN apt-get update \
	&& apt-get install -y libmagic-dev build-essential git  \
	&& apt-get clean  \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /backend

COPY pyproject.toml poetry.lock /backend/
COPY gunicorn.conf.py /backend
COPY startup.sh /backend

RUN pip install poetry==1.1.15 && poetry config virtualenvs.create false && poetry install --no-dev

COPY --from=build /frontend /backend/frontend

ENV PORT 8000

EXPOSE $PORT

RUN git clone https://github.com/spamhaus/spamassassin-dqs
RUN chmod +x startup.sh
CMD bash -c "./startup.sh";gunicorn -k uvicorn.workers.UvicornWorker app:app
