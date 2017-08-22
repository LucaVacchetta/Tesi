# Automazione del deploy di Kubernetes

Innanzitutto questo processo di automazione su un ambiente multi-cloud è stato possibile grazie all'utilizzo di [Terraform](https://www.terraform.io/).
<br>
## Setup

Per l'installazione di Terraform su Ubuntu è necessario seguire la guida presente nella documentazione: [terraform-installation.pdf](https://github.com/LucaVacchetta/Tesi/blob/master/Kubernetes/doc/terraform-installation.pdf).

## Deploy

Per un corretto Deploy di Kubernetes in un ambiente multi-cloud (in questo caso su Softlayer e AWS) è indispensabile seguire i seguenti passi:
1. Creare una chiave ssh, necessaria per il trasferimento sicuro dei files di setup ai cloud provider, con il seguente comando:
    - ```ssh-keygen -t rsa```
2. Ricavare dalla chiave ssh appena creata l'analoga in formato PEM, in modo che sia compatibile con i requisiti richiesti da AWS, per far ciò è necessario digitare i seguenti comandi:
    - ```openssl rsa -in ~/.ssh/id_rsa -outform pem > id_rsa.pem```
    - ```chmod 700 id_rsa.pem```
3. Aggiungere le proprie credenziali (sia di __Softlayer__ che di __AWS__) nel file [kubernetes.tf](kubernetes.tf)
4. Al fine di verificare quali e quante macchine verranno create lanciare il comando:
    - ```terraform plan```
5. Creare effettivamente le macchine, che in questo caso saranno tre server virtuali di cui due di Softlayer ed uno di AWS aventi relativamente:
    - Il nodo master di Kubernetes (Softlayer).
    - Un nodo worker di Kubernetes (Softlayer).
    - Un altro nodo worker di Kubernetes (AWS).<br>
  con il seguente comando:
    - ```terraform apply```

Ora se si desidera accedere al nodo master è necessario collegarsi tramite l'uso di ssh, cioè:
  - ```ssh root@<IP address of master node>```

Infine, se si desidera eliminare le macchine create, è consigliabile seguire questi passi:
- Verificare quali macchine verranno eliminate, digitando questo comando:
  - ```terraform plan -destroy```
- Se tutto è ok, si procede con l'eliminazione con questo comando:
  - ```terraform destroy```

<br>

__NB:__ Tutti questi comandi vanno lanciati da __QUESTA CARTELLA.__
