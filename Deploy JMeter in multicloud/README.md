# Deploy di JMeter su Kubernetes in multi-cloud
<br>

## Setup

Prima di effettuare il deploy di JMeter è necessario seguire i seguenti passi:
- Entrare nella console del master.
- Assegnare ad ogni nodo presente sul cluster la label __*cloud-provider*__ con uno di questi valori:
  - Softlayer
  - AWS

 che, in sostanza, indica a quale cloud provider appartiene, per far ciò lanciare il seguente comando:
  - ```kubectl label nodes <node-name> <label-key>=<label-value>```
  ad esempio:
  - ```kubectl label nodes 172.30.52.18 cloud-provider=Softlayer```

__NB:__ la fase di Setup è necessaria per avere la possibilità di assegnare un determitato numero di repliche di JMeter slave ad uno specifico cloud-provider. Inoltre va fatta manualmente solamente perché, al momento, la feature che permette di inserire delle label ad un nodo in fase di creazione del nodo stesso è presente solanto nella versione alpha di Kubernetes (cioè non stabile).

## Deploy
Per un corretto deploy di JMeter sul proprio cluster di Kubernetes è necessario seguire i passi sotto-indicati nell'ordine specificato:
- Creare il __volume__ lanciando i seguenti comandi (__DALLA CARTELLA VOLUME__):
  - ```kubectl create -f persistentVolume.yaml```
  - ```kubectl create -f persistentVolumeClaim.yaml```
- __NB:__ Dato che si sta utilizzando un volume di tipo hostPath (solo perché non si ha a disposizione un NFS) __è NECESSARIO__ copiare la cartella /mnt/jmeter-volume presente sul nodo in cui è stato creato il PersistentVolume su tutti i nodi del cluster.
- Creare il __master__ lanciando il comando (__DALLA CARTELLA MASTER__):
  - ```kubectl create -f deployment.yaml```
- __NB:__ Nuovamente __è NECESSARIO__ copiare la cartella /mnt/jmeter-volume presente sul nodo in cui è stato creato il PersistentVolume su tutti i nodi del cluster, cosicché gli slave possano accedere al file in comune.
- Creare lo __slave__ di Softlayer lanciando il comando (__DALLA CARTELLA SOFTLAYER__):
  - ```kubectl create -f deployment.yaml```
- Creare lo __slave__ di AWS lanciando il comando (__DALLA CARTELLA AWS__):
  - ```kubectl create -f deployment.yaml```

<br>
In seguito se si desidera aumentare il numero di slave presenti, è necessario lanciare il comando:
- ```kubectl scale deployment jm-slave-softlayer --replicas=3``` #cioè farà sì che ci saranno 3 repliche dello slave nel cloud di Softlayer

<br>

Successivamente per entrare nella console del master è necessario lanciare:

- ```kubectl attach < nome del pod di JMeter master > -i -t``` ad esempio:
  - ```kubectl attach jm-master-3040992684-qp4qz -i -t```
- Infine per lanciare il test desiderato su tutti gli slave presenti nel cluster è indispensabile lanciare il comando ```jmeter``` nella modalità senza GUI con il seguente parametro: ```-r``` vale a dire il comando sarà nella forma:
  - ```jmeter -n -r -t testcase.jmx```
