# VOLUME

All'interno di questa cartella sono presenti i seguenti due file:
- __persistentVolume.yaml__: contiene la configurazione del volume (cioè alloca fisicamente dello spazio) sul cluster di Kubernetes.
- __persistentVolumeClaim.yaml__: contiene la configurazione necessaria affinché i pod riescano ad utilizzare lo spazio precedentemente allocato, cioè i pod accedono al volume fisico mediante l'uso di reclami (*claim*) per motivi di sincronizzazione.
