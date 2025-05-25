#!/bin/bash
# Create shared network for all services
docker network create openshaw-services 2>/dev/null || echo "Network already exists"