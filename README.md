kubeadm join 192.168.10.115:6443 --token co4sv3.faselvqrwum8ti22 --discovery-token-ca-cert-hash sha256:78835e624c360128211af0650eda1596cc5f836794d384be2a4815cc9954d911

Name:         admin-token-5rbhn
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin
              kubernetes.io/service-account.uid: f36eb17d-34e7-11e9-acb6-005056959c47

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi10b2tlbi01cmJobiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImYzNmViMTdkLTM0ZTctMTFlOS1hY2I2LTAwNTA1Njk1OWM0NyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbiJ9.UrqC7jAJdjEVQYfjOqNYvD7yOm06OhN-ZyR4pjH2ZhLTMYaTUQqkszeYQXo-BB68L0L7yAhdfJa78xUENsqiq2_0Ssy4kR_9d5sEmzAj4YJhVF-5jUoPqfN_v8yF8VsYa2cTTmT7S-aTo8Yru8ZGV8z5k_BEfTmQpzXc0dvjTwiX4GrABaNei1UwUsPJH7YnLVbYFBcgIWwafbhRANLc5qLfVu0hiwz1Fo6-z7caJ1x1Ny6XePir9cgedzH9uLORGafLrTn2GXwKKmw4VJ1Kd-q4C65g1RpK-exMGCdD-qxVFQ0tbI-KYiiF77_RT6qoIhfkAsiGbTNLwHmcrylJVg

kubectl describe pod kube-proxy-jzvts --namespace=kube-system