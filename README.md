# README

A basic project that can be used as a starting point when I need a project to recreate an issue.

## Docker

To build on Mac Silicon, run this command:

```shell
docker build \
  --build-arg BUILD_RUNTIME=linux-arm64 \
  --tag api --file ./Dockerfile .
```

To run on Mac Silicon, run this command:

```shell
docker run -p 8888:8080 --rm api
```