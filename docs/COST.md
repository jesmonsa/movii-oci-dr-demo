# Control de costo (trial ~USD 500 / 2 meses)

> No son precios oficiales: es una hoja para **estimar y validar** en la consola
> (Cost Analysis). El objetivo es no agotar el crédito antes de 2 meses.

## Palancas aplicadas

- Región **alterna apagada** por defecto (`node_count_standby=0`, OPNsense `STOPPED`).
- **Apagado programado** noches y fines de semana (tag `Schedule=office-hours`).
- Shapes mínimos (`Flex 1 OCPU / 8GB`).
- MySQL **sin nodo HeatWave analítico**.
- Load Balancer **flexible 10 Mbps**.
- `deploy_standby=false` mientras no ensayes failover.

## Hoja de estimación (completar con Cost Analysis)

| Recurso | Cant. | Horas/mes activas | Costo/mes (estimar) |
|---|---|---|---|
| OPNsense (compute Flex) | 1-2 | ~330 (con apagado) | |
| Nodos OKE (Flex) | 1 (+1 demo) | ~330 | |
| MySQL DB System | 1-2 | ~330 | |
| Load Balancer flexible | 1-2 | continuo | |
| Block storage / boot vols | varios | continuo | |
| DNS + Traffic Management | 1 | continuo | (bajo) |
| **Total estimado** | | | |

## Regla de oro

Al terminar cada sesión de pruebas: `terraform destroy` o, como mínimo, dejar la
alterna apagada y los nodos OKE en 0.
