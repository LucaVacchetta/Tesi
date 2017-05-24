# Deploy di JMeter su Kubernetes
Questo repository è composto dalle seguenti cartelle:
- master
- slave
- volume


Per un corretto deploy di JMeter sul proprio cluster di Kubernetes è necessario seguire i passi sotto-indicati nell'ordine specificato:
1. Effettuare il clone di questo repository in locale, tramite il comando:
  - ```git clone https://github.com/LucaVacchetta/Tesi.git```
2. Creare il __volume__ con i seguenti comandi che __DEVONO ESSERE LANCIATI DENTRO LA CARTELLA VOLUME__:
  - ```kubectl create -f persistentVolume.yaml```
  - ```kubectl create -f persistentVolumeClaim.yaml```
3. Creare il __master__ lanciando il comando (__DALLA CARTELLA MASTER__):
  - ```kubectl create -f deployment.yaml```
4. Creare lo __slave__ lanciando il comando (__DALLA CARTELLA SLAVE__):
    - ```kubectl create -f deployment.yaml```

In seguito se si desidera aumentare il numero di slave presenti, è necessario lanciare il comando:
- ```kubectl scale deployment jm-slave --replicas=3``` #cioè andrà a creare 3 repliche dello slave

Successivamente per entrare nella console del master è necessario lanciare:

- ```kubectl attach < nome del pod di JMeter master > -i -t``` ad esempio:
  - ```kubectl attach jm-master-3040992684-qp4qz -i -t```
- Infine per lanciare il test desiderato su tutti gli slave presenti nel cluster è indispensabile lanciare il comando ```jmeter``` nella modalità senza GUI con il seguente parametro: ```-r``` vale a dire il comando sarà nella forma:
  - ```jmeter -n -r -t testcase.jmx```
