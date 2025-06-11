ARG BUILD_CONFIGURATION=Release

# Use the RID "linux-musl-arm64" for Alpine based images on Apple Silicon machines
# Use the RID "linux-arm64" for Debian based images on Apple Silicon machines
# https://docs.microsoft.com/en-us/dotnet/core/rid-catalog
ARG BUILD_RUNTIME=linux-x64

# tag listing: https://mcr.microsoft.com/en-us/artifact/mar/dotnet/sdk/tags
# preview tag listing: https://mcr.microsoft.com/en-us/artifact/mar/dotnet/nightly/sdk/tags
ARG SDK_TAG=9.0-noble

# tag listing: https://mcr.microsoft.com/en-us/artifact/mar/dotnet/runtime-deps/tags
# preview tag listing: https://mcr.microsoft.com/en-us/artifact/mar/dotnet/nightly/runtime-deps/tags
ARG RUN_TAG=9.0-noble-chiseled-extra

# https://hub.docker.com/_/microsoft-dotnet-sdk/
FROM mcr.microsoft.com/dotnet/sdk:$SDK_TAG AS sdk

FROM sdk AS restore
WORKDIR /app/src
COPY ./ /app/src/
ARG BUILD_RUNTIME
RUN dotnet --info
RUN dotnet restore --runtime "$BUILD_RUNTIME"

FROM restore AS publish
WORKDIR /app/src
ARG BUILD_CONFIGURATION
ARG BUILD_RUNTIME
RUN dotnet publish ODataStarter/ODataStarter.csproj \
    --output ./output/api/ \
    --configuration "$BUILD_CONFIGURATION" \
    --runtime "$BUILD_RUNTIME" \
    --no-restore \
    --self-contained 

# https://hub.docker.com/_/microsoft-dotnet-runtime-deps/
FROM mcr.microsoft.com/dotnet/runtime-deps:$RUN_TAG AS run
# The -extra image varient includes the icu-libs and sets DOTNET_SYSTEM_GLOBALIZATION_INVARIANT to true
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false LC_ALL=en_GB.UTF-8 LANG=en_GB.UTF-8

FROM run
WORKDIR /app/api
COPY --from=publish /app/src/output/api/ ./

# image=api \
# && docker build --no-cache=true \
#       --build-arg BUILD_RUNTIME=<RID> --build-arg SDK_TAG=<TAG> --build-arg RUN_TAG=<TAG> \
#       --tag $image --file ./Dockerfile . \
# && docker run -p <PORT_OF_YOUR_CHOICE>:8080 --rm $image

# Examples:
# docker build \
#   --build-arg BUILD_RUNTIME=linux-musl-arm64 --build-arg SDK_TAG=8.0-alpine --build-arg RUN_TAG=8.0-alpine-extra \
#   --tag api --file ./Dockerfile .

# docker build \
#   --build-arg BUILD_RUNTIME=linux-arm64 --build-arg SDK_TAG=8.0-jammy --build-arg RUN_TAG=8.0-jammy-chiseled-extra \
#   --tag api --file ./Dockerfile .

USER $APP_UID
ENTRYPOINT ["./ODataStarter"]