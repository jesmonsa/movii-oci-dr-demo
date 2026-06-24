# Guion de la demo en vivo — Disaster Recovery multi-región (Movii)

**Objetivo:** que Movii vea, en vivo, cómo el servicio sobrevive a la caída de la región principal
y cómo se implementa, paso a paso. **Duración:** 30–40 min. **Audiencia:** equipo técnico de Movii
(arquitectos, redes, BD) + un líder/decisor.

> Mensaje central a repetir: *“Un plan de DR no probado se comporta como un plan manual durante una
> crisis. Hoy lo probamos.”*

---

## 0) Antes de empezar (checklist del presentador)

- [ ] Región principal (Ashburn) **desplegada y verde**: app en OKE respondiendo, MySQL OK.
- [ ] Región alterna (Chicago) **encendida** para la demo (`scripts/standby_up.sh`), réplica MySQL al día.
- [ ] Dominio piloto con NS delegados a OCI; steering FAILOVER activo; Health Check en verde.
- [ ] Dos pestañas listas: la **app por su dominio** y la **consola OCI** (Traffic Management + Health Checks).
- [ ] Terminal con `kubectl` apuntando a Chicago y OCI CLI listo.
- [ ] **Ensayar el failover una vez antes** de la reunión (nunca demostrar en frío).

---

## 1) Encuadre (3–4 min) — *hablado, sin pantalla*

- Recordar el problema real: los incidentes de 2026 fueron **regionales**; la contingencia actual
  “reenvía y vuelve” a Ashburn, y si Ashburn cae completa, no hay dónde levantar.
- Qué van a ver hoy: entrada **global** (DNS + Traffic Management), réplica de datos, y **failover
  orquestado**. “No es una arquitectura bonita en PDF; es un switch que vamos a accionar en vivo.”

## 2) Estado normal (4–5 min) — *pantalla: app + consola*

1. Abrir la app por su **dominio** → mostrar: **“Región que atiende: Ashburn”** y el contador.
2. Click en `/write` un par de veces → el contador sube. “Esto escribe en MySQL HeatWave en Ashburn.”
3. En la consola: **Traffic Management** → steering FAILOVER (primario Ashburn, secundario Chicago)
   y el **Health Check en verde**.
4. Mostrar que MySQL de Chicago es **réplica de solo-lectura** (canal de réplica, lag bajo).

## 3) El incidente: failover (8–10 min) — *el momento clave*

1. **Provocar la caída** de la entrada principal (apagar la entrada de Ashburn o romper `/health`).
2. Mostrar el **Health Check pasando a rojo** para el answer primario.
3. Traffic Management **retira** Ashburn y sirve Chicago.
4. **Refrescar la app por el mismo dominio** → ahora dice **“Región que atiende: Chicago”**
   (TTL 30s; si el navegador cachea, usar `curl` o incógnito).
5. Click en `/write` → el contador **sigue avanzando** desde Chicago. “Las transacciones continúan.”
6. (Si aplica) Mostrar la **promoción de MySQL** y/o el **DR Plan de Full Stack DR** (precheck + ejecución).

## 4) Evidencia: RTO/RPO observado (3–4 min)

- Mostrar el **tiempo** de respuesta desde Chicago (RTO observado) y que **no se perdieron escrituras**
  confirmadas (RPO observado ≈ lag de réplica). Conectar con la **matriz RTO/RPO** del documento.

## 5) Switchback (2–3 min)

- Restablecer Ashburn, Health Check en verde, el steering vuelve al primario.
- Reducir el node pool de Chicago a 0 para ahorrar.

## 6) Cómo se construye + costo (3–4 min)

- Mostrar el repo: **un solo `terraform apply`** (o el botón *Deploy to Oracle Cloud*).
- Palancas de costo: alterna apagada, apagado nocturno/fines de semana, shapes mínimos.
  “Corrió en un trial de ~USD 500 para 2 meses.”

## 7) Cierre y decisiones (3 min)

Pedir: región alterna, servicios críticos, **RTO/RPO**, dominio piloto, alcance, permisos OCI y
presupuesto mínimo de standby. Agendar la sesión técnica de implementación.

---

## Plan B (si algo falla en vivo)

- **El DNS no conmuta a tiempo:** mostrar el Health Check en rojo y explicar el TTL; usar
  `curl --resolve` para forzar y demostrar que Chicago responde.
- **La app en Chicago no levanta:** tener el node pool ya escalado (no en 0) antes de la reunión.
- **La réplica MySQL no está al día:** mostrar el lag y explicar el activo-pasivo.
- **Regla de oro:** si la demo en vivo se complica, cambiar a la **grabación del ensayo previo**.

---

## Frases de apoyo (consultivo, no vendedor)

- “Diseñamos de más a menos: partimos de lo robusto y ajustamos a lo costo-eficiente con sus números.”
- “Full Stack DR orquesta cómputo, BD y OKE; el DNS y el firewall son piezas complementarias que integramos.”
- “Esto no reemplaza definir RTO/RPO con el negocio; lo hace medible y repetible.”
