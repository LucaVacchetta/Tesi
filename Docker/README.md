# Deploy di JMeter su Kubernetes
La parte riguardante il deploy di JMeter su Kubernetes è composta dalle seguenti cartelle, che contengono l'implementazione dei containers master e slave di JMeter:
- master
- slave
- volume

<br>

## Deploy
Per un corretto deploy di JMeter sul proprio cluster di Kubernetes è necessario seguire i passi sotto-indicati nell'ordine specificato:
- Effettuare il clone di questo repository in locale, tramite il comando:
  - ```git clone https://github.com/LucaVacchetta/Tesi.git```
- Creare il __volume__ lanciando i seguenti comandi (__DALLA CARTELLA VOLUME__):
  - ```kubectl create -f persistentVolume.yaml```
  - ```kubectl create -f persistentVolumeClaim.yaml```
- Creare il __master__ lanciando il comando (__DALLA CARTELLA MASTER__):
  - ```kubectl create -f deployment.yaml```
- Creare lo __slave__ lanciando il comando (__DALLA CARTELLA SLAVE__):
    - ```kubectl create -f deployment.yaml```

<br>

In seguito se si desidera aumentare il numero di slave presenti, è necessario lanciare il comando:
- ```kubectl scale deployment jm-slave --replicas=3``` #cioè andrà a creare 3 repliche dello slave

<br>

Successivamente per entrare nella console del master è necessario lanciare:

- ```kubectl attach < nome del pod di JMeter master > -i -t``` ad esempio:
  - ```kubectl attach jm-master-3040992684-qp4qz -i -t```
- Infine per lanciare il test desiderato su tutti gli slave presenti nel cluster è indispensabile lanciare il comando ```jmeter``` nella modalità senza GUI con il seguente parametro: ```-r``` vale a dire il comando sarà nella forma:
  - ```jmeter -n -r -t testcase.jmx```
