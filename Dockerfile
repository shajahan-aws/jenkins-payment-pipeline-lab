FROM python:3.12-slim

# Build Metadata Arguments
ARG BUILD_NUMBER=unknown
ARG GIT_COMMIT=unknown
ARG BRANCH_NAME=unknown

# Set Image Metadata Labels
LABEL org.label-schema.build-number=$BUILD_NUMBER \
      org.label-schema.vcs-ref=$GIT_COMMIT \
      org.label-schema.branch=$BRANCH_NAME

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=8080 \
    HOST=0.0.0.0 \
    BUILD_NUMBER=$BUILD_NUMBER \
    GIT_COMMIT=$GIT_COMMIT \
    BRANCH_NAME=$BRANCH_NAME

EXPOSE 8080

CMD ["python", "app.py"]