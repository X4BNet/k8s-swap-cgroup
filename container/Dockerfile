FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    gawk \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

COPY entry.sh /

CMD ["bash", "/entry.sh"]