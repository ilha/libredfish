FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    g++ \
    make \
    cmake \
    libcurl4-openssl-dev \
    libjansson-dev

COPY . /app

WORKDIR /app

# Build the project
RUN cmake -D CMAKE_C_FLAGS="-D_DEBUG" -D CMAKE_CXX_FLAGS="-D_DEBUG" .  && \
    make && \
    make install && \
    cp bin/redfishcli /usr/local/bin/redfishcli 

ENTRYPOINT ["/usr/local/bin/redfishcli"]
