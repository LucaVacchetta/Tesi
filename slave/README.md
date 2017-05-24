# SLAVE

All'interno di questa cartella è presente:
- __Dockerfile__: cioè il file su cui si basa l'immagine con tag __*slave*__ caricata sul docker hub pubblico (https://index.docker.io/v1/) nel repository chiamato: __*tesijmeterkubernetes/jmeter*__
- __launch_etcd_and_jmeter_signal_handler.sh__: è lo script che contiene l'entrypoint dello slave.
- __deployment.yaml__: è il file che contiene la configurazione dello slave all'interno del cluster Kubernetes.
