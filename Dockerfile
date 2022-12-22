FROM golang:1.19.4 as build

ENV CGO_ENABLED=0

ARG BUILD_VERSION

WORKDIR /app

COPY . .

RUN go mod download

RUN go build -ldflags="-X 'main.Version=${BUILD_VERSION}'" -o health-check cmd/healthcheck/* &&\
    go build -ldflags="-X 'main.Version=${BUILD_VERSION}'" -o peak-technical-test-go cmd/web/*

FROM gcr.io/distroless/static@sha256:c3c3d0230d487c0ad3a0d87ad03ee02ea2ff0b3dcce91ca06a1019e07de05f12

ARG BUILD_VERSION
ARG BUILD_DATE

LABEL org.opencontainers.image.title="peak-technical-test-go"
LABEL org.opencontainers.image.description="Micro-service that powers the shopping cart of an e-commerce website written in Go."
LABEL org.opencontainers.image.authors="James Oliver"
LABEL org.opencontainers.image.source="https://github.com/J-R-Oliver/peak-technical-test-go"
LABEL org.opencontainers.image.licenses="Unlicense"
LABEL org.opencontainers.image.revision="${BUILD_VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"

USER nonroot:nonroot

EXPOSE 8080
ENV PORT=8080

WORKDIR /app

COPY --from=build --chown=nonroot:nonroot --chmod=500 /app/health-check .

COPY --from=build --chown=nonroot:nonroot --chmod=500 /app/peak-technical-test-go .
COPY --from=build --chown=nonroot:nonroot --chmod=400 /app/configuration.yaml .

HEALTHCHECK --interval=25s --timeout=3s --retries=2 CMD ["./health-check"]

CMD ["/app/peak-technical-test-go"]
