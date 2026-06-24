# Enrutamiento hub-and-spoke a través del firewall (OPNsense)

> Diseño rescatado de las referencias de Iwan Hoogendoorn (pfSense en el hub) y adaptado
> a nuestro módulo `network` + `opnsense`. Es la pieza que en v0.1 quedó como `TODO(tenancy)`:
> **forzar que el tráfico entre spokes (y hacia on-premises) pase por el firewall del hub**.

## Idea clave

En OCI, los spokes **no** se comunican directamente entre sí. El DRG concentra el tráfico y,
mediante **DRG Route Distributions** y **DRG Route Tables por attachment**, se obliga a que
todo el tráfico inter-spoke / on-prem entre primero al **hub VCN**, donde la instancia de
firewall (OPNsense) lo inspecciona y reenvía. La instancia debe tener
`skip_source_dest_check = true` (ya lo tenemos) y ser el **next hop** en la route table del hub.

```
Spoke A ──► DRG ──► (DRG RT del attachment de A: destino spokes/on-prem ─► HUB_VCN_ATTACHMENT)
                         │
                     HUB VCN ──► VCN RT subred privada: destino spokes/on-prem ─► IP PRIVADA OPNsense
                         │                                   (internet ─► NAT GW)
                     OPNsense (inspecciona y reenvía)
```

## Qué agregar a nuestro módulo `network` (cuando validemos contra el tenancy)

1. **DRG Route Distribution (import)** que acepta los attachments de VCN:
   - `oci_core_drg_route_distribution` (tipo `IMPORT`)
   - `oci_core_drg_route_distribution_statement` (match por `ATTACHMENT_TYPE = VCN`, acción `ACCEPT`)

2. **DRG Route Table por attachment de spoke** que envía los destinos remotos al hub:
   - `oci_core_drg_route_table` con `import_drg_route_distribution_id` apuntando al import.
   - Reglas estáticas: `destino = <CIDR de otro spoke / on-prem>`, `next_hop_drg_attachment_id = <attachment del HUB VCN>`.
   - Asociar esa route table al spoke: en `oci_core_drg_attachment.spoke` setear `drg_route_table_id`.

3. **Subred privada en el HUB** (hoy el hub solo tiene subred pública para OPNsense) y su
   **VCN route table** con next hop = **IP privada de OPNsense**:
   - `route_rules { destination = <CIDR spoke/on-prem>, network_entity_id = <private IP OCID de la VNIC de OPNsense> }`
   - `route_rules { destination = "0.0.0.0/0", network_entity_id = <NAT GW> }`
   - Esto crea una dependencia: la route table del hub necesita la **IP privada de OPNsense**,
     así que se crea **después** del módulo `opnsense` (pasar `firewall_private_ip` como variable).
   - Truco para romper el ciclo: asignar una **IP privada estática** a la VNIC de OPNsense y
     resolver su OCID con `data oci_core_private_ips` + `depends_on = [module.opnsense]`.

4. **OPNsense**: configurar en el appliance las reglas de firewall/NAT y el reenvío entre
   interfaces (esto es semi-manual vía la GUI/API la primera vez; documentar en `ansible/`).

### Variable de activación sugerida

```hcl
variable "route_via_firewall" {
  description = "Fuerza el tráfico inter-spoke/on-prem a través de OPNsense (hub)."
  type        = bool
  default     = false   # off por defecto para no romper el plan base
}
```

Con `false`, el demo funciona con el enrutamiento simple actual (NAT + DRG directo).
Con `true`, se activa la inserción del firewall estilo Iwan Hoogendoorn.

## Opcional — Site-to-Site VPN (simular el Fortinet/on-premises de Movii)

El segundo tutorial de Iwan detalla la VPN IPSec OCI ↔ on-premises sobre hub-and-spoke.
Lo implementamos como módulo opcional `modules/vpn` (CPE + IPSec sobre el DRG + rutas estáticas).
Parámetros de referencia (validar con la política de Movii): Fase 1 IKEv1/IKEv2, AES-256,
SHA-256, DH Group 2/5; Fase 2 ESP, AES-256, HMAC-SHA2-256, PFS Group 5. Importar la ruta del
túnel IPSec en el DRG Route Distribution (igual que los spokes).

Para el **DR demo** esto es *nice-to-have*; el núcleo (DNS failover + OKE + MySQL + FSDR) no lo
requiere.

## Resumen de decisión

- **Rescatar:** el patrón de **DRG route distribution + route tables por attachment + next-hop
  al firewall** (puntos 1-3). Es la forma canónica en OCI de hacer la inserción del firewall y
  completa nuestro `TODO(tenancy)`.
- **Opcional:** módulo de **Site-to-Site VPN** (`modules/vpn`) para simular el on-premises de Movii.
- **No cambiar:** seguimos con **OPNsense** (no pfSense) y mantenemos el alcance multi-región
  + DB/identidad/FSDR, que las referencias no cubren.

## Referencias

- FoggyKitchen — OCI Multiregion Compute Failover (patrón base de failover):
  https://github.com/foggykitchen/foggykitchen-landing-zone-orchestrator/blob/main/examples/oci/multiregion/compute_failover/basic/README.md
- Iwan Hoogendoorn — Route Hub and Spoke VCN with pfSense Firewall in the Hub VCN:
  https://www.iwanhoogendoorn.nl/index.php/Route_Hub_and_Spoke_VCN_with_pfSense_Firewall_in_the_Hub_VCN
- Iwan Hoogendoorn — Connect On-premises to OCI using IPSec VPN with Hub and Spoke Routing:
  https://iwanhoogendoorn.nl/index.php/Connect_On-premises_to_OCI_using_an_IPSec_VPN_with_Hub_and_Spoke_VCN_Routing_Architecture
