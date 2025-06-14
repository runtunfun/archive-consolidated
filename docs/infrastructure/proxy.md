# Reverse Proxy Infrastructure

Traefik fungiert als zentraler Reverse Proxy und Load Balancer für alle Homelab-Services. Es stellt automatische SSL-Terminierung, Service-Discovery und Routing basierend auf Host-Headern bereit.

## Traefik Übersicht

### Funktionalitäten

Traefik bietet folgende Kernfunktionen für das Homelab:

- **Automatische Service-Discovery**: Erkennt Docker-Services automatisch über Labels
- **SSL-Terminierung**: Let's Encrypt Zertifikate mit automatischer Erneuerung
- **Load Balancing**: Verteilung der Last bei mehreren Service-Instanzen
- **Middleware**: HTTP-Redirects, Authentication, Rate Limiting
- **Dashboard**: Web-Interface für Monitoring und Konfiguration

### Architektur-Entscheidungen

!!! info "Warum Traefik statt nginx?"
    - **Native Docker-Integration**: Automatische Service-Discovery
    - **Dynamische Konfiguration**: Keine manuellen Config-Reloads
    - **Let's Encrypt Integration**: Automatische Zertifikatsverwaltung
    - **Modern Design**: HTTP/2, HTTP/3, gRPC Support

## Docker Swarm Konfiguration

### Hauptkonfiguration

**Datei:** `/opt/homelab/traefik/docker-compose.yml`

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    command:
      # API und Dashboard
      - "--api.dashboard=true"
      - "--api.insecure=false"
      
      # Provider
      - "--providers.docker=true"
      - "--providers.docker.swarmMode=true"
      - "--providers.docker.exposedbydefault=false"
      
      # Entrypoints
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      
      # Let's Encrypt mit netcup DNS-Challenge für Wildcards
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=netcup"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@enzmann.online"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      
      # Logging
      - "--log.level=INFO"
      - "--accesslog=true"
      
    ports:
      - "80:80"
      - "443:443"
      
    environment:
      # netcup API Credentials
      NETCUP_CUSTOMER_NUMBER: "${NETCUP_CUSTOMER_NUMBER}"
      NETCUP_API_KEY: "${NETCUP_API_KEY}"
      NETCUP_API_PASSWORD: "${NETCUP_API_PASSWORD}"
      
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt
      
    labels:
      # Traefik Dashboard
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik-01.lab.enzmann.online`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"
      - "traefik.http.routers.dashboard.middlewares=auth"
      
      # Basic Auth für Dashboard
      - "traefik.http.middlewares.auth.basicauth.users=admin:$$2y$$10$$..."  # htpasswd generiert
      
    networks:
      - traefik
      
    deploy:
      placement:
        constraints:
          - node.role == manager

volumes:
  traefik_letsencrypt:

networks:
  traefik:
    external: true
```

### Environment-Konfiguration

**Datei:** `/opt/homelab/traefik/.env`

```bash
# netcup API Credentials (von netcup Customer Control Panel)
NETCUP_CUSTOMER_NUMBER=123456
NETCUP_API_KEY=abcdefghijklmnopqrstuvwxyz
NETCUP_API_PASSWORD=your-api-password

# Basic Auth Credentials (htpasswd generiert)
TRAEFIK_ADMIN_USER=admin
TRAEFIK_ADMIN_PASSWORD_HASH=$2y$10$...
```

## Service-Integration

### Standard-Labels für Services

Jeder Service, der über Traefik erreichbar sein soll, benötigt diese Labels:

```yaml
labels:
  # Traefik aktivieren
  - "traefik.enable=true"
  
  # Routing-Regel (Host-basiert)
  - "traefik.http.routers.${SERVICE_NAME}.rule=Host(`${SERVICE_NAME}-01.lab.enzmann.online`)"
  
  # SSL-Zertifikat
  - "traefik.http.routers.${SERVICE_NAME}.tls.certresolver=letsencrypt"
  
  # Service-Port (wenn nicht 80)
  - "traefik.http.services.${SERVICE_NAME}.loadbalancer.server.port=${SERVICE_PORT}"
  
  # Middleware (optional)
  - "traefik.http.routers.${SERVICE_NAME}.middlewares=auth"
```

### Home Assistant Beispiel

```yaml
# /opt/homelab/homeassistant/docker-compose.yml
services:
  homeassistant:
    image: homeassistant/home-assistant:stable
    volumes:
      - ha_config:/config
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homeassistant.rule=Host(`ha-prod-01.lab.enzmann.online`)"
      - "traefik.http.routers.homeassistant.tls.certresolver=letsencrypt"
      - "traefik.http.services.homeassistant.loadbalancer.server.port=8123"

networks:
  traefik:
    external: true
```
