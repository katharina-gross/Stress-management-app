# Строим бинарник
FROM golang:1.24 AS builder
WORKDIR /app

# Копируем и подтягиваем зависимости до того, как добавим код,
# чтобы кэширование работало правильно
COPY go.mod go.sum ./
RUN go mod download

# Теперь копируем весь код и билдим
COPY . .
RUN go build -o main .

# Финальный минимальный образ
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
&& rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/main ./
EXPOSE 8080
ENTRYPOINT ["/app/main"]
