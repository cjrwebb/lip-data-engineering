
# View all attached containers
docker ps -a

# Remove all exited containers that are still attached 
docker container prune -f

# Stop and remove all running containers
docker container stop $(docker container ls -aq)
docker container prune -f

# List all running docker instances
docker ps

# run pgcli
uv run pgcli -h localhost -p 5432 -u root -d ny_taxi

# Run PostgreSQL on the network
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:18


# In another terminal, run pgAdmin on the same network
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4


# Build the docker network and pipeline
docker build -t taxi_ingest:v001

# Run the ingest script as a docker container on the network
docker run -it --rm \
  --network=pg-network \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-pass=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_trips

# Run ingest script after having run docker compose up
docker run -it --rm \
  --network=workshop-1-demo_default \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-pass=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_trips


# Clean up space used by docker

# Clean up containers that are not currently running:
docker container prune

# Clean up docker images in memory/cached
docker image prune -a

# Remove all docker volumes (storage allocation)
docker volume prune

# Remove any unused docker networks
docker network prune

# Remove all docker resources (use with caution)
docker system prune -a --volumes

# Clean up local environment to free up resources
# Remove parquet files
rm *.parquet

# Remove Python cache
rm -rf __pycache__ .pytest_cache

# Remove virtual environment (if using venv)
rm -rf .venv
