# Validación

## Offline (sin tenancy) — ejecutada en v0.1

- **Sintaxis HCL**: los 25 archivos `.tf` parsean sin error.
- **Variables**: cada `var.X` usada está declarada en su módulo.
- **Outputs**: cada `module.<x>.<output>` referenciado desde la raíz existe.
- **Argumentos de módulo**: coinciden con las variables declaradas (sin args
  desconocidos ni requeridos faltantes).

> Limitación: la validación offline **no** comprueba el esquema del provider OCI
> (nombres exactos de atributos/recursos). Eso requiere `terraform validate/plan`.

### Reproducir la validación de sintaxis

```bash
pip install python-hcl2
python3 - <<'PY'
import hcl2, glob
for f in glob.glob('**/*.tf', recursive=True):
    hcl2.load(open(f))
print('HCL OK')
PY
```

## Con tenancy (recomendado)

```bash
terraform init
terraform validate     # esquema del provider
terraform plan         # plan real (no crea nada)
```

Revisa los `TODO(tenancy)` del repo (OPNsense image OCID, versión OKE, réplica MySQL,
esquema de Scheduler/FSDR) antes del `apply`.
