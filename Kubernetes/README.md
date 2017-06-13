# Automazione del deploy di Kubernetes

Innanzitutto questo processo di automazione su un ambiente multi-cloud è stato possibile grazie all'utilizzo di [Terraform](https://www.terraform.io/).
<br>
## Setup

Per tanto è necessario installare:
- [Terraform](https://www.terraform.io/intro/getting-started/install.html).
- [Terraform-provider-softlayer](https://github.com/softlayer/terraform-provider-softlayer) (versione di terraform creata da IBM per renderlo compatibile con softlayer. __NB:__ è anche necessario installare [GO dalla versione 1.8](https://medium.com/@patdhlk/how-to-install-go-1-8-on-ubuntu-16-04-710967aa53c9) in poi).

## Deploy

Per un corretto Deploy di Kubernetes in un ambiente multi-cloud (in questo caso su Softlayer e AWS) è indispensabile seguire i seguenti passi:
1. Aggiungere le proprie credenziali (sia di __Softlayer__ che di __AWS__) nel file [kubernetes.tf](kubernetes.tf)
2. Al fine di verificare quali e quante macchine verranno create lanciare il comando:
    - ```terraform plan```
3. Creare effettivamente le macchine, che in questo caso saranno tre server virtuali di cui due di Softlayer ed uno di AWS aventi relativamente:
  - Il nodo master di Kubernetes (Softlayer).
  - Un nodo worker di Kubernetes (Softlayer).
  - Un altro nodo worker di Kubernetes (AWS).
<br>
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
