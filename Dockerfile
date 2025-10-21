FROM python:3.9-alpine3.13
LABEL maintainer="shapkaoleksiiu@gmail.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
WORKDIR /app
EXPOSE 8000

ARG DEV=false
ENV DEV=$DEV
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    echo "=== Contents of requirements.txt ===" && \
    cat /tmp/requirements.txt && \
    echo "=== End of requirements.txt ===" && \
    echo "=== File size ===" && \
    ls -la /tmp/requirements.txt && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    echo "DEV value: $DEV" && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    chown -R django-user:django-user /py

# Install dev dependencies as django-user
USER django-user
RUN if [ "$DEV" = "true" ]; then echo "Installing dev dependencies..." && /py/bin/pip install --no-cache-dir flake8; fi

# Clean up as root
USER root
RUN rm -rf /tmp

# Copy app directory after installing dependencies
COPY ./app /app

ENV PATH="/py/bin:$PATH"

USER django-user