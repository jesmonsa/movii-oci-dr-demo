# Runbook de failover / switchback (demo)

## Failover (principal caída -> alterna)

1. **Simula la caída**: detén la entrada principal (apaga OPNsense/instancia o el LB),
   o haz que `/health` falle. El **Health Check** de Traffic Management lo detecta.
2. **DNS conmuta** automáticamente a la IP de Chicago (steering FAILOVER).
3. **Promueve la réplica MySQL** en Chicago:
   - Consola: MySQL > Channel > *Disable*, y deja el DB System como primario de escritura, o
   - usa Full Stack DR (DR Plan: *Failover*).
4. Escala el **node pool de OKE** en Chicago si estaba en 0:
   ```bash
   oci ce node-pool update --node-pool-id <ID> --size 1
   ```
5. Verifica la app respondiendo desde `REGION=standby` y que `/write` inserta.

## Switchback (regreso ordenado a la principal)

1. Restablece la principal y su MySQL como primario; reconfigura el canal
   principal <- alterna si hubo escrituras en la alterna.
2. Reactiva el answer primario en el steering (Health Check en verde).
3. Reduce el node pool de Chicago a 0 para ahorrar.

## Con Full Stack DR

Genera el **DR Plan**, corre **prechecks** y ejecuta **Switchover** (planeado) o
**Failover** (emergencia) desde la consola de FSDR. Ver `modules/fsdr/README.md`.
