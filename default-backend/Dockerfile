FROM golang:1.12.1-alpine3.9 as builder

WORKDIR /go/src/default-backend
COPY main.go .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -ldflags '-w -s' -o main default-backend

FROM scratch

EXPOSE 8080

COPY --from=builder /go/src/default-backend/main /
COPY ./www /www
COPY ./etc /etc

CMD ["/main"]