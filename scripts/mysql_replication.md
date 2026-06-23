# Canal de réplica MySQL HeatWave (Ashburn -> Chicago)

> Objetivo: la réplica de Chicago queda en **solo-lectura** y se promueve en el failover.

## 1) En la principal (Ashburn): usuario de replicación

Conecta al MySQL principal (desde un bastion/pod en la VCN) y crea el usuario:

```sql
CREATE USER 'repl'@'%' IDENTIFIED BY 'ReplP4ss!';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
```

## 2) Habilita el canal en la réplica (Chicago)

Opción A — Terraform (módulo mysql), pasando los datos de la principal:

```hcl
module "mysql_standby" {
  # ...
  enable_replication = true
  source_hostname    = "<IP_PRIVADA_O_HOSTNAME_MYSQL_PRINCIPAL>"
  source_username    = "repl"
  source_password    = "ReplP4ss!"
}
```

Opción B — consola: MySQL > Channels > Create channel (source = principal, target = réplica).

## 3) Verifica el lag

```sql
SHOW REPLICA STATUS\G   -- en MySQL 8: SHOW SLAVE STATUS en versiones previas
```

> Requisitos de red: DRG + RPC entre regiones, rutas hacia el CIDR remoto y reglas
> NSG/Security List que permitan el puerto 3306 entre ambas subredes privadas.
