NGINX Plus gRPC Demo
====================

Prerequisites
-------------
 - Docker runtime
 - NGINX Plus R23 or later (Docker image) tagged as nginx-plus:latest
 - cd ~ && git clone https://github.com/grpc/grpc
 - grpc_cli installed on demo host. See https://github.com/grpc/grpc/blob/master/BUILDING.md


Environment
-----------
NGINX Plus is configured as a load balancer and reverse proxy for 3 different gRPC services. It
provides a single IP:port for multiple services and routes requests to the correct backend.

 - amex_text is used to demonstrate gRPC-native health checks with `mandatory`
 - route_guide is used to demonstrate load balancing, gRPC streaming, and naive gRPC health checks
 - hello_world is used to demonstrate JWT authentication to gRPC services

```
                                      +-----------------+----+
                                  +---|   amex_text_1   | _2 |
                                  |   +-----------------+----+
                                  |                       
+--------+     +--------------+   |   +-----------------+----+
| Client |-----|  nginx_plus  |---+---|  route_guide_1  | _2 |
+--------+     +--------------+   |   +-----------------+----+
                                  |                       
                                  |   +-----------------+----+
                                  +---|  hello_world_1  | _2 |
                                      +-----------------+----+
```

Preparation
-----------
1. Prepare demo gRPC services
 - git clone https://github.com/americanexpress/grpc-k8s-health-check
 - docker compose build

2. Prepare browser for dashboard
 - http://localhost:8080/dashboard.html

Demo
----
0. Orientation
 - Show docker-compose.yml
 - `docker-compose up` in new terminal
 - Show NGINX Plus dashboard http://localhost:8080/dashboard.html
 - Show the NGINX Plus configuration at **nginx_conf.d/grpc_proxy.conf**

1. Show full gRPC support for all message types
 - Run the route_guide client `cd ~/grpc/examples/python/route_guide && python3 route_guide_client.py | less`
 - Show NGINX logs `docker logs grpc_demo_nginx_plus_1`
 - Show dashboard
 - Introduce grpc_cli for remaining demos
 - `grpc_cli --noremotedb --json-output call localhost:50051 RouteGuide.GetFeature 'latitude: 407838351,longitude: -746143763' --protofiles route_guide.proto --proto_path ~/grpc/examples/protos | jq`
 - Show that we are truly sending binary protobuf messages (integers are not readable in ASCII column)
 - `grpc_cli tobinary route_guide.proto --proto_path ~/grpc/examples/protos routeguide.Point 'latitude: 407838351,longitude: -746143763' | hexdump -C`

2. Demonstrate load balancing and mandatory health checks
 - Intro the American Express ProcessText service
 - `grpc_cli --noremotedb --json-output call localhost:50051 ProcessText.upper 'text: "nginx "' --proto_path grpc-k8s-health-check/api --protofiles api.proto | jq`
 - Observe **backend** response header
 - `docker kill grpc_demo_amex_text_1`
 - Watch health check fail, repeat tests
 - `docker restart grpc_demo_amex_text_1`
 - Show that requests only proccessed by **_2** until health check passes

3. Authentication demo
 - Intro **hello_world** service
 - `grpc_cli --noremotedb --json-output call localhost:50051 Greeter.SayHello 'name: "Liam"' --proto_path ~/grpc/examples/protos --protofiles helloworld.proto | jq`
 - Observe unauthenticated response
 - Generate token
 - `cat jwt_claimset.json | create_jwt.sh -exp 1 hs256 mysecret -`
 - `grpc_cli --noremotedb --json-output call localhost:50051 Greeter.SayHello 'name: "Joe"' --proto_path ~/grpc/examples/protos --protofiles helloworld.proto -metadata token:$JWT | jq`

 4. Wrap-up
 - Show the NGINX Plus configuration at **nginx_conf.d/grpc_proxy.conf** 
 - Explain JWT config
 - Routing config
 - Health check config


