> helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
> kubectl create ns prometheus
> helm upgrade --install prometheus prometheus-community/prometheus -n prometheus -f prometheus-values.yaml
> helm repo add grafana https://grafana.github.io/helm-charts
> helm repo update
> helm upgrade --install grafana grafana/grafana -n prometheus -f grafana-values.yaml

# Prometheus Helm Chart values: https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/prometheus/values.yaml
# Grafana Helm Chart values: https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml