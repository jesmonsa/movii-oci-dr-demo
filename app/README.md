# App Java de demostración

App mínima (HTTP + JDBC) que escribe en **MySQL HeatWave** y muestra la **región** que atiende.
Sirve para evidenciar el failover: tras conmutar, la misma URL responde desde la región alterna.

## Build y push a OCIR

```bash
# 1) Login a OCIR (region-key ej. iad para Ashburn, ord para Chicago)
docker login <region-key>.ocir.io -u '<tenancy-namespace>/<usuario>' -p '<auth-token>'

# 2) Build y push
docker build -t <region-key>.ocir.io/<tenancy-namespace>/movii-dr-demo:latest app/
docker push <region-key>.ocir.io/<tenancy-namespace>/movii-dr-demo:latest
```

## Deploy en OKE

```bash
oci ce cluster create-kubeconfig --cluster-id <OKE_OCID> --file ~/.kube/config --region <region>
kubectl apply -f app/k8s/configmap.yaml
cp app/k8s/secret.example.yaml app/k8s/secret.yaml   # completa DB_HOST/USER/PASS
kubectl apply -f app/k8s/secret.yaml
# Edita deployment.yaml -> image: tu imagen OCIR
kubectl apply -f app/k8s/deployment.yaml
kubectl apply -f app/k8s/service.yaml
kubectl get svc dr-demo-lb   # IP pública del LB -> úsala en el steering DNS
```

En la región alterna, cambia `REGION: standby` en el ConfigMap antes de aplicar.
