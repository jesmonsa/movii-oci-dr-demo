# Contribuir

## Validar antes de hacer commit

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Si no tienes el provider descargado aún, `terraform init` lo trae. Para validar solo
sintaxis sin tenancy, puedes usar el parser de HCL (ver `docs/VALIDATION.md`).

## Convenciones

- No subir `terraform.tfvars`, claves, kubeconfig ni `secret.yaml` (ver `.gitignore`).
- Recursos etiquetados con `Schedule=office-hours` entran al apagado programado.
- Cambios de costo (shapes, conteos) deben quedar reflejados en `docs/COST.md`.
