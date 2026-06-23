# Preflight — antes del primer `terraform apply`

## 1) Límites de servicio del trial (verificar en consola: Governance > Limits, Quotas)

- **Regiones**: confirma que `us-ashburn-1` y `us-chicago-1` estén suscritas.
- **Compute**: cores disponibles para `VM.Standard.E4.Flex` (OPNsense + nodos OKE).
- **OKE**: que el servicio esté habilitado y permita clusters.
- **MySQL**: que el shape `MySQL.2` (u otro económico) esté disponible.
- **Load Balancer flexible**: mínimo 10 Mbps.

## 2) Imagen de OPNsense (Marketplace) en CADA región

1. Marketplace > busca "OPNsense" (o una imagen BSD/firewall equivalente).
2. Acepta los términos y suscribe la imagen en Ashburn y en Chicago.
3. Copia el **OCID de la imagen** por región -> `opnsense_image_ocid_primary` / `_standby`.

## 3) Clave SSH

```bash
ssh-keygen -t rsa -b 4096 -f movii-dr -N ""
cat movii-dr.pub   # -> ssh_public_key
```

## 4) OCIR (registry para la imagen de la app)

- Anota el **namespace del tenancy** (Tenancy details > Object Storage Namespace).
- Crea un **Auth Token** (User > Auth Tokens) para `docker login`.

## 5) IAM

- Si eres administrador del tenancy, puedes dejar `operator_group_ocid=""`.
- Si no, crea un grupo, agrega tu usuario y pasa su OCID en `operator_group_ocid`
  para que el módulo `iam` le otorgue permisos (MySQL, OKE, red, DNS, FSDR).

## 6) Versión de OKE

```bash
oci ce cluster-options get --cluster-option-id all --query 'data."kubernetes-versions"'
```
Ajusta `kubernetes_version` a una disponible.
