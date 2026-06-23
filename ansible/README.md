# Ansible (configuración complementaria)

Lo que no cubre Terraform de forma limpia se automatiza aquí:

- **OPNsense**: reglas de firewall/NAT y enrutamiento entre redes (vía API/SSH del appliance).
- **App**: despliegue de manifiestos en OKE (`kubectl apply`).

## Uso

```bash
cp inventory.example.ini inventory.ini   # completa IPs/credenciales
ansible-playbook -i inventory.ini playbook-app.yml
```

> La configuración fina de OPNsense suele requerir su API/GUI la primera vez
> (asistente inicial). Documenta aquí las reglas aplicadas para reproducibilidad.
