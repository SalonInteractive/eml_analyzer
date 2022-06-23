FROM python:3.9-slim-buster as build


RUN apt-get update
RUN apt-get -y install curl gnupg make g++
RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apt-get -y install nodejs

COPY ./frontend /frontend
WORKDIR /frontend
RUN npm install && npm run build && rm -rf node_modules

# prod env
FROM python:3.9-slim-buster

RUN apt-get update \
	&& apt-get install -y libmagic-dev build-essential  \
	&& apt-get clean  \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /backend

COPY pyproject.toml poetry.lock /backend/
COPY gunicorn.conf.py /backend

RUN pip3 install poetry && poetry config virtualenvs.create false && poetry install --no-dev

COPY --from=build /frontend /backend/frontend

ENV PORT 8000

EXPOSE $PORT

CMD gunicorn -k uvicorn.workers.UvicornWorker app:app
