# MASTER

All'interno di questa cartella è presente:
- __Dockerfile__: cioè il file su cui si basa l'immagine con tag __*master*__ caricata sul docker hub pubblico (https://index.docker.io/v1/) nel repository chiamato: __*tesijmeterkubernetes/jmeter*__
- Bash scripts:
  - __jmeter_to_all_slaves.sh__: è lo script che contiene l'alias del comando ```jmeter``` affinché aggiorni il file di configurazione di JMeter inserendoci gli indirizzi IP degli slave, appresi mediante l'utilizzo di ETCD.
  - __launch_etcd.sh__: è lo script che contiene l'entrypoint del master.
- __deployment.yaml__: è il file che contiene la configurazione del master all'interno del cluster Kubernetes.
