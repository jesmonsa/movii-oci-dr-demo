# Acceso al MySQL privado (crear usuario de réplica, pruebas)

El DB System MySQL está en una **subred privada**. Para conectarte:

## Opción A — OCI Cloud Shell + port forwarding (rápido)

Usa un host o pod dentro de la VCN como salto. La forma más simple en la demo es un
pod temporal en OKE:

```bash
kubectl run mysql-cli --rm -it --image=mysql:8 -- bash
# dentro del pod:
mysql -h <IP_PRIVADA_MYSQL> -u admin -p
```

## Opción B — OCI Bastion service (gestionado)

1. Crea un Bastion en la subred privada del spoke (Networking > Bastion).
2. Crea una **Port Forwarding session** al endpoint MySQL (puerto 3306).
3. Conecta vía el túnel SSH que entrega la consola.

## Crear el usuario de replicación (en la principal)

```sql
CREATE USER 'repl'@'%' IDENTIFIED BY 'ReplP4ss!';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
```

Luego habilita el canal en la réplica (ver `scripts/mysql_replication.md`).
