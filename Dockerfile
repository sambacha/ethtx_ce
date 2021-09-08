FROM python:3.8 AS builder

ENV PYTHONDONTWRITEBYTECODE 1

RUN mkdir /app
WORKDIR /app
ADD . /app
COPY Pip* /app/

ARG GIT_URL
ENV GIT_URL=$GIT_URL

ARG GIT_SHA
ENV GIT_SHA=$GIT_SHA

ARG CI=1
RUN pip install --upgrade pip && \
    pip install pipenv && \
    pipenv install #--dev --system --deploy --ignore-pipfile

FROM tiangolo/meinheld-gunicorn:python3.8

COPY --from=builder /app .
ENV PATH=/root/.local/bin:$PATH

EXPOSE 5000

CMD cd /app && pipenv run gunicorn --workers 4 --max-requests 4000 --timeout 600 --bind :5000 wsgi:app
