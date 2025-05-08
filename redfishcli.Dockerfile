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
RUN cmake .  && \
    make && \
    make install && \
    cp bin/redfishcli /usr/local/bin/redfishcli 

CMD ["/usr/local/bin/redfishcli"]
