# SSL/TLS Infrastructure

Das SSL/TLS-Setup stellt sicher, dass alle Homelab-Services über verschlüsselte HTTPS-Verbindungen mit echten Let's Encrypt-Zertifikaten verfügbar sind.

## Let's Encrypt Setup

### netcup DNS API Konfiguration

**1. API-Zugang aktivieren:**

1. Bei netcup im Customer Control Panel anmelden
2. **Stammdaten → API** aufrufen
3. **API-Key** und **API-Password** generieren
4. **DNS-API** Berechtigung aktivieren

**2. DNS-Struktur bei netcup:**

```bash
# Wildcard für alle Services (automatisch von Traefik verwaltet)
*.enzmann.online          → DNS-Challenge TXT Records

# Keine manuellen A-Records für lokale Services nötig!
# Traefik erstellt automatisch TXT-Records für Let's Encrypt
```

### DNS Challenge Konfiguration

**Traefik DNS Challenge Setup:**

```yaml
command:
  # Let's Encrypt mit netcup DNS-Challenge für Wildcards
  - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
  - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=netcup"
  - "--certificatesresolvers.letsencrypt.acme.email=admin@enzmann.online"
  - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"

environment:
  # netcup API Credentials
  NETCUP_CUSTOMER_NUMBER: "${NETCUP_CUSTOMER_NUMBER}"
  NETCUP_API_KEY: "${NETCUP_API_KEY}"
  NETCUP_API_PASSWORD: "${NETCUP_API_PASSWORD}"
```

!!! warning "DNS Challenge Vorteile"
    - **Wildcard-Zertifikate**: Ein Zertifikat für alle Subdomains
    - **Lokale Services**: Funktioniert auch für interne Services
    - **Firewall-freundlich**: Keine eingehenden Verbindungen nötig

## Zertifikatsverwaltung

### Automatische Erneuerung

Let's Encrypt-Zertifikate haben eine Gültigkeitsdauer von 90 Tagen. Traefik erneuert sie automatisch:

```bash
# Zertifikats-Status prüfen
docker exec -it $(docker ps -q -f name=traefik) cat /letsencrypt/acme.json | jq '.letsencrypt.Certificates[]'

# Manuelle Erneuerung erzwingen
docker service update --force traefik_traefik
```

### Zertifikatsspeicher

```bash
# ACME-Daten werden persistent gespeichert
/var/lib/docker/volumes/traefik_traefik_letsencrypt/_data/acme.json

# Backup der Zertifikate
docker run --rm -v traefik_letsencrypt:/source -v /opt/homelab/backup:/backup alpine tar czf /backup/letsencrypt-$(date +%Y%m%d).tar.gz -C /source .
```

### Middleware-Konfiguration

**Basic Authentication:**

```yaml
labels:
  # Basic Auth Middleware erstellen
  - "traefik.http.middlewares.auth.basicauth.users=admin:$$2y$$10$$..."
  
  # Middleware anwenden
  - "traefik.http.routers.dashboard.middlewares=auth"
```

**HTTP zu HTTPS Redirect:**

```yaml
command:
  # Globaler Redirect von HTTP zu HTTPS
  - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
  - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
```

**IP Whitelist:**

```yaml
labels:
  # IP-basierte Zugriffsbeschränkung
  - "traefik.http.middlewares.internal-only.ipwhitelist.sourcerange=192.168.1.0/24,192.168.100.0/22"
  - "traefik.http.routers.internal-service.middlewares=internal-only"
```

## Service-spezifische SSL-Konfiguration

### Grafana Beispiel

```yaml
# /opt/homelab/monitoring/docker-compose.yml (Ausschnitt)
services:
  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SERVER_ROOT_URL=https://grafana-01.lab.enzmann.online
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana-01.lab.enzmann.online`)"
      - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"
```

### Portainer Beispiel

```yaml
# /opt/homelab/portainer/docker-compose.yml
services:
  portainer:
    image: portainer/portainer-ce:latest
    command: -H unix:///var/run/docker.sock
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(`portainer-01.lab.enzmann.online`)"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"
      # IP-Whitelist für Management-Interface
      - "traefik.http.routers.portainer.middlewares=internal-only"
```

## Deployment und Management

### Docker Network Setup

```bash
# Traefik-Network erstellen (einmalig)
docker network create --driver overlay traefik

# Service-interne Kommunikation
docker network create --driver overlay homelab-internal
```

### Traefik Stack deployen

```bash
# Stack deployen
cd /opt/homelab/traefik
docker stack deploy -c docker-compose.yml traefik

# Status prüfen
docker service ls | grep traefik
docker service logs traefik_traefik --tail 50

# Dashboard-Zugriff testen
curl -k https://traefik-01.lab.enzmann.online
```

### Service-Integration testen

```bash
# Neuen Service hinzufügen
cd /opt/homelab/new-service
docker stack deploy -c docker-compose.yml new-service

# SSL-Zertifikat-Erstellung überwachen
docker service logs traefik_traefik --tail 50 -f

# HTTPS-Zugriff testen
curl -k https://new-service-01.lab.enzmann.online
```

## Troubleshooting

### Zertifikat-Probleme

**1. Zertifikat nicht erstellt:**

```bash
# Traefik Logs prüfen
docker service logs traefik_traefik --tail 50

# netcup API Credentials testen
curl -X POST https://ccp.netcup.net/run/webservice/servers/endpoint.php \
  -H "Content-Type: application/json" \
  -d '{"action":"login","param":{"customernumber":"123456","apikey":"YOUR_API_KEY","apipassword":"YOUR_API_PASSWORD"}}'

# ACME Challenge prüfen
docker exec -it $(docker ps -q -f name=traefik) cat /letsencrypt/acme.json | jq .
```

**2. Service nicht erreichbar über HTTPS:**

```bash
# DNS Auflösung testen (lokal)
nslookup ha-prod-01.lab.enzmann.online 192.168.1.3
dig ha-prod-01.lab.enzmann.online @192.168.1.3

# Traefik Dashboard prüfen
curl -k https://traefik-01.lab.enzmann.online
# Router und Services Status kontrollieren

# Service Labels überprüfen
docker service inspect homeassistant_homeassistant | jq '.[0].Spec.Labels'

# Port-Mapping testen
curl -v http://192.168.1.41:8123  # Direkter Service-Zugriff
```

**3. Wildcard-Zertifikat Probleme:**

```bash
# DNS Challenge manuell testen
dig TXT _acme-challenge.lab.enzmann.online
dig TXT _acme-challenge.iot.enzmann.online

# netcup DNS API manuell testen
# (DNS-Record erstellen/löschen via API)

# Let's Encrypt Rate Limits prüfen
# https://letsencrypt.org/docs/rate-limits/
```

### Performance-Optimierung

**HTTP/2 und HTTP/3 aktivieren:**

```yaml
command:
  # HTTP/2 Support
  - "--entrypoints.websecure.http.protocols.h2c=true"
  
  # HTTP/3 Support (experimentell)
  - "--experimental.http3=true"
  - "--entrypoints.websecure.http3.advertisedport=443"
```

**Compression Middleware:**

```yaml
labels:
  # Gzip-Kompression
  - "traefik.http.middlewares.gzip.compress=true"
  - "traefik.http.routers.service.middlewares=gzip"
```

### Security Best Practices

!!! danger "Sicherheitshinweise"
    - **Private Keys**: acme.json-Datei hat sensible Daten (600 permissions)
    - **API Keys**: netcup-Credentials niemals in Git speichern
    - **Basic Auth**: Starke Passwörter für Admin-Interfaces
    - **IP Whitelist**: Management-Interfaces nur intern erreichbar

**Sichere Permissions:**

```bash
# ACME-Datei absichern
chmod 600 /var/lib/docker/volumes/traefik_letsencrypt/_data/acme.json

# Environment-Dateien absichern
chmod 600 /opt/homelab/traefik/.env
```

**Monitoring und Alerting:**

```yaml
# Traefik Metriken für Prometheus
command:
  - "--metrics.prometheus=true"
  - "--metrics.prometheus.addEntryPointsLabels=true"
  - "--metrics.prometheus.addServicesLabels=true"
```

## Aufwandsschätzung

| Aufgabe | Zeit | Schwierigkeit |
|---------|------|---------------|
| **netcup API Setup** | 30 Min | Niedrig |
| **Traefik Basis-Installation** | 1-2 Stunden | Mittel |
| **Erste SSL-Zertifikate** | 1 Stunde | Mittel |
| **Service-Integration (pro Service)** | 15-30 Min | Niedrig |
| **Middleware-Konfiguration** | 1-2 Stunden | Mittel |
| **Troubleshooting & Optimierung** | 1-3 Stunden | Hoch |
| **Gesamt (Basis-Setup)** | **3-5 Stunden** | **Mittel** |
| **Gesamt (Vollständig)** | **5-8 Stunden** | **Hoch** |

!!! success "Nach erfolgreichem Setup"
    Alle Services sind über verschlüsselte HTTPS-Verbindungen mit echten Let's Encrypt-Zertifikaten erreichbar. Die automatische Zertifikatserneuerung sorgt für wartungsfreien Betrieb.
