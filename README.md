# SOC-Lab: A Fully Automated Open Source SOC Environment

This project deploys a complete Security Operations Center (SOC) lab environment using Docker Compose. It is designed to be fully automated, requiring zero manual configuration after launch.

The stack includes:
- **TheHive 5**: Security Incident Response Platform
- **Cortex 3**: Powerful observable analysis engine
- **MISP**: Open Source Threat Intelligence Platform
- **MinIO**: S3-compatible object storage
- **Elasticsearch, Cassandra, MySQL, Redis**: Backend data stores

---

## Prerequisites

- Docker Engine
- Docker Compose

---

## Getting Started

### 1. Launch the Environment

All configurations are pre-set, and secrets are defined in the `.env` file. To launch the entire stack, navigate to the `soc-lab` directory and run:

```bash
docker compose up -d --build
```

The `--build` flag is recommended on the first run to ensure the initializer container is built correctly.

It will take several minutes for all services to start, initialize, and become healthy. The startup order is managed with `depends_on` and `healthcheck` policies in the `docker-compose.yml` file.

### 2. Verify the Deployment

Once the containers are running, you can verify that all services are accessible by running the healthcheck script:

```bash
chmod +x scripts/healthcheck.sh
./scripts/healthcheck.sh
```

You should see an `ONLINE` status for all services.

---

## Accessing Services

The following services are exposed on your local machine. The default credentials are set in the `.env` file.

| Service         | URL                          | Username                 | Password       |
|-----------------|------------------------------|--------------------------|----------------|
| **TheHive**     | http://localhost:9000        | `admin@soc-lab.local`    | `Password123!` |
| **Cortex**      | http://localhost:9001        | `admin@soc-lab.local`    | `Password123!` |
| **MinIO Console** | http://localhost:9003        | `minioadmin`             | `minioadmin-password` |
| **MISP**        | https://localhost:8443       | `admin@misp.local`       | `admin`        |

**Note on MISP:** MISP uses a self-signed SSL certificate, so you will need to accept the security warning in your browser.

---

## How It Works

- **Configuration**: Service configurations are mounted from the `thehive/` and `cortex/` directories.
- **Secrets**: All passwords and API keys are managed in the `.env` file.
- **Initialization**: An `soc-initializer` container runs automatically on startup to:
  1. Create the MinIO bucket for TheHive.
  2. Set the admin API key in MISP.
  3. Enable default analyzers in Cortex.
  This container will exit after its tasks are complete.

---

## Shutting Down

To stop and remove all containers, networks, and volumes, run:

```bash
docker compose down -v
```
