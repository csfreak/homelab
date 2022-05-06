FROM golang:1.17.1 as builder

RUN cd / && \
    git clone https://github.com/cosandr/fah-exporter
WORKDIR /fah-exporter

RUN go get -v ./... && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o fah-exporter -installsuffix cgo .
    # CGO_ENABLED=0 go build -o /fah-exporter -a -ldflags '-extldflags "-static"' .

FROM scratch

COPY --from=builder /fah-exporter/fah-exporter /fah-exporter

ENTRYPOINT ["/fah-exporter"]