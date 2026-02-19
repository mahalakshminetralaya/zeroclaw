# Build stage
FROM rust:1.76-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy source code
COPY . .

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates libssl3 && \
    rm -rf /var/lib/apt/lists/*

# Copy the binary from builder
COPY --from=builder /app/target/release/zeroclaw /usr/local/bin/zeroclaw

# Make it executable
RUN chmod +x /usr/local/bin/zeroclaw

# Create config directory
RUN mkdir -p /root/.zeroclaw

WORKDIR /root

# Run zeroclaw
CMD ["zeroclaw", "gateway"]
