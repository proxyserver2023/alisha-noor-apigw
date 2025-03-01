FROM --platform=$BUILDPLATFORM golang:alpine AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src

# restore dependencies
COPY go.mod go.sum ./
RUN go mod download
COPY . .

ARG SKAFFOLD_GO_GCFLAGS
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -gcflags="${SKAFFOLD_GO_GCFLAGS}" -o /go/bin/apigw .

FROM scratch
WORKDIR /src
COPY --from=builder /go/bin/apigw /src/server

# Definition of this variable is used by 'skaffold debug' to identify a golang binary.
# Default behavior - a failure prints a stack trace for the current goroutine.
# See https://golang.org/pkg/runtime/
ENV GOTRACEBACK=single

EXPOSE 8080
ENTRYPOINT [ "/src/server" ]
