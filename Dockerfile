# Stage 1: Build the Go application
FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o /chat_server_service ./http/grpc_server/main.go

# Stage 2: Create a minimal runtime image
FROM alpine:3.21

RUN apk add --no-cache ca-certificates

WORKDIR /root/

COPY --from=builder /chat_server_service .

EXPOSE 50051

CMD ["./chat_server_service"]