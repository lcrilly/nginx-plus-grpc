# This Dockerfile runs the RouteGuide server from
# https://grpc.io/docs/tutorials/basic/python.html

FROM python
RUN git clone -b v1.33.1 https://github.com/grpc/grpc
RUN pip install grpcio-tools
WORKDIR grpc/examples/python/route_guide

EXPOSE 50051
CMD ["python", "route_guide_server.py"]
