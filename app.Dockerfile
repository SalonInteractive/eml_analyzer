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
	&& apt-get install -y libmagic-dev build-essential git  \
	&& apt-get clean  \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /backend

COPY pyproject.toml poetry.lock /backend/
COPY gunicorn.conf.py /backend

RUN pip3 install poetry && poetry config virtualenvs.create false && poetry install --no-dev

COPY --from=build /frontend /backend/frontend

# Spam assassin Steps
RUN git clone https://github.com/spamhaus/spamassassin-dqs
RUN cd spamassassin-dqs/3.4.1+ \ 
      && sed -i -e "s/your_DQS_key/$SPAMHAUS_DQS_KEY/g" sh.cf \
      && sed -i -e "s/your_DQS_key/$SPAMHAUS_DQS_KEY/g" sh_hbl.cf \
      && sed -i -e "s/<config_directory>/\/etc\/mail\/spamassassin/g" sh.pre \
      && cp SH.pm /etc/mail/spamassassin \ 
      && cp sh.cf /etc/mail/spamassassin \ 
      && cp sh_scores.cf /etc/mail/spamassassin \ 
      && cp sh.pre /etc/mail/spamassassin
# Uncomment if HBL (paid) enabled
# && cp sh_hbl.cf /etc/mail/spamassassin
# && cp sh_hbl_scores.cf /etc/mail/spamassassin

ENV PORT 8000

EXPOSE $PORT

CMD gunicorn -k uvicorn.workers.UvicornWorker app:app
