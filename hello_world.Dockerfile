FROM golang
RUN go get google.golang.org/grpc/examples/helloworld/greeter_server
EXPOSE 50051
CMD ["/go/bin/greeter_server"]
