FROM golang:1.20
WORKDIR /app
COPY main.go .
RUN go build -o main main.go
CMD ["./main"]