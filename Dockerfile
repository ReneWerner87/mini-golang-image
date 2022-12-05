####################################################################################################
## Builder
####################################################################################################
FROM golang:alpine AS builder

# Create appuser
ENV USER=hello
ENV UID=10001

WORKDIR /app

ENV UPX_VERSION=4.0.1
ENV MAGICPAK_VERSION=1.3.2

# install upx for binary compression - https://upx.github.io/
ADD https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-amd64_linux.tar.xz /tmp/upx.tar.xz
RUN cd /tmp \
      && tar --strip-components=1 -xf upx.tar.xz \
      && mv upx /bin/ \
      && rm upx.tar.xz

# copy the source code
COPY ./ .

# building the appication
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /app/bin/app ./main.go

# compress the binary
RUN upx --ultra-brute -qq /app/bin/app && \
    upx -t /app/bin/app

####################################################################################################
## Executor
####################################################################################################
FROM scratch
COPY --from=builder /app/bin/app /app/bin/app

CMD ["/app/bin/app"]
