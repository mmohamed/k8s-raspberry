

#### Create
```
# Copy TLS secret and remove it from app.yaml
kubectl get secret front-tls -n=front --export -o yaml | kubectl apply -n=springbatch -f -
# OR Get it and inject it in env 
kubectl get secret front-tls -n=front -o 'go-template={{index .data "tls.key"}}'
kubectl get secret front-tls -n=front -o 'go-template={{index .data "tls.cert"}}'
```

```
sed -i "s|{{crt}}|`echo $CRT`|" app.yaml
sed -i "s|{{key}}|`echo $KEY`|" app.yaml
sed -i "s|{{host}}|[YOUR-HOSTNAME]|" app.yaml
sed -i "s|{{commit}}|[GIT_COMMIT]|" app.yaml
```

```
kubectl apply -f mysql.yaml
kubectl apply -f app.yaml
```


#### Update
```
commitID=$(git rev-parse --short HEAD)
kubectl patch deployment springbatch -n springbatch -p "{"spec":{"template":{"metadata":{"labels":{"commit":"$commitID"}}}}}"
```