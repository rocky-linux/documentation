��    ,      |  ;   �      �  �   �  Y   �  �   �  2   �     �     �     �       G     7   U     �  D   �  0   �  6   !  �   X  `   �  T   \  �   �  >   S	  �   �	  '   g
  	   �
  8   �
  t  �
     G  �   ^  h   �  K   d  �   �  j   G  �   �  �   :  *   -     X  2   \  �  �     j     �     �  2   �  "   �  R   �  p   Q  #  �  �   �  d   �  �     ;   �          5     R     l  N   r  @   �  "     \   %  6   �  6   �  �   �  t   �  f   )  �   �  G   F  �   �  0   �  
   �  B   �  �       �  �   �  u   �   Y   �   �   T!  ~   �!  �   n"  %  #  5   D$     z$  3   ~$  �  �$     �'     �'     �'  9   �'  8   (  G   V(  u   �(              (                &                                  
   	      +                               ,           $      *             )   '          #              %   "                  !                  In the examples below, the administration station has the IP address 172.16.1.10, the managed station 172.16.1.11. It is up to you to adapt the examples according to your IP addressing plan.
 !!! Abstract
    To follow this training, you will need at least 2 servers under Rocky8:
 !!! Warning
    The opening of SSH or WinRM flows to all clients from the Ansible server, makes it a critical element of the architecture that must be carefully monitored.
 ![The features of Ansible](images/ansible-001.png) # Ansible Basics ## Exercices results ## The Ansible vocabulary ****
 **Knowledge**: :star: :star: :star:     
**Complexity**: :star: :star:
 **Objectives**: In this chapter you will learn how to:
 **Reading time**: 30 minutes
 **agentless** (it does not require specific deployments on clients), **idempotent** (same effect each time it is run) :checkered_flag: **ansible**, **module**, **playbook** :heavy_check_mark: Implement Ansible;       
:heavy_check_mark: Apply configuration changes on a server;   
:heavy_check_mark: Create first Ansible playbooks;   
 A **collection**: a collection includes a logical set of playbooks, roles, modules, and plugins. A **module**: a module abstracts a task. There are many modules provided by Ansible. A **role**: a role allows you to organize the playbooks and all the other necessary files (templates, scripts, etc.) to facilitate the sharing and reuse of code. Ansible centralizes and automates administration tasks. It is: As Ansible is push-based, it will not keep the state of its targeted servers between each of its executions. On the contrary, it will perform new state checks each time it is executed. It is said to be stateless. Create en empty file with `0644` rights Examples: In this chapter you will learn how to work with Ansible. It uses the **SSH** protocol to remotely configure Linux clients or the **WinRM** protocol to work with Windows clients. If none of these protocols is available, it is always possible for Ansible to use an API, which makes Ansible a real Swiss army knife for the configuration of servers, workstations, docker services, network equipment, etc. (Almost everything in fact). It will help you with: The **facts**: these are global variables containing information about the system (machine name, system version, network interface and configuration, etc.). The **handlers**: these are used to cause a service to be stopped or restarted in the event of a change. The **inventory**: a file containing information about the managed servers. The **management machine**: the machine on which Ansible is installed. Since Ansible is **agentless**, no software is deployed on the managed servers. The **playbooks**: a simple file in yaml format defining the target servers and the tasks to be performed. The **tasks**: a task is a block defining a procedure to be executed (e.g. create a user or a group, install a software package, etc.). To offer a graphical interface to your daily use of Ansible, you can install some tools like Ansible Tower (RedHat), which is not free, its opensource counterpart Awx, or other projects like Jenkins and the excellent Rundeck can also be used. You can check the syntax of your playbook: ``` ``` $ ansible-playbook --syntax-check play.yml ``` ``` ansible ansible_clients --become -m group -a "name=Paris" ansible ansible_clients --become -m group -a "name=Tokio" ansible ansible_clients --become -m group -a "name=NewYork" ansible ansible_clients --become -m user -a "name=Supervisor" ansible ansible_clients --become -m user -a "name=Supervisor uid=10000" ansible ansible_clients --become -m user -a "name=Supervisor uid=10000 groups=Paris" ansible ansible_clients --become -m dnf -a "name=tree" ansible ansible_clients --become -m systemd -a "name=crond state=stopped" ansible ansible_clients --become -m copy -a "content='' dest=/tmp/test force=no mode=0644" ansible ansible_clients --become -m dnf -a "name=* state=latest" ansible ansible_clients --become -m reboot ``` application deployments automation, configuration management, orchestration (when more than 1 target is in use). provisioning (deploying a new VM), the first one will be the **management machine**, Ansible will be installed on it. the second one will be the server to configure and manage (another Linux than Rocky Linux will do just as well). Project-Id-Version: 
PO-Revision-Date: 2021-08-17 15:09+0200
Last-Translator: Automatically generated
Language-Team: none
Language: fr
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=2; plural=(n > 1);
X-Generator: Poedit 3.0
     Dans les exemples ci-dessous, la station d'administration a l'adresse IP 172.16.1.10, la station gérée 172.16.1.11. Il vous appartient d'adapter les exemples en fonction de votre plan d'adressage IP.
 !!! Abstract
    Pour suivre cette formation, vous aurez besoin d'au moins 2 serveurs sous Rocky8.:
 !!! Warning
    L’ouverture des flux SSH vers l’ensemble des clients depuis le serveur Ansible font de lui un élément critique de l’architecture qu’il faudra attentivement surveiller.
 ![Les fonctionnalités d’Ansible](images/ansible-001.png) Principes de base d'Ansible ## Corrections des exercices ## Le vocabulaire Ansible ****
 **Connaissances** : :star: :star: :star:     
**Complexité** : :star: :star:
 **Objectifs** : Dans ce chapitre, vous allez apprendre comment:
 **Temps de lecture** : 30 minutes
 **agentless** (sans agent, il ne nécessite aucun déploiement spécifique sur les clients), **idempotent** (il a le même effet à chaque passage) :checkered_flag: **ansible**, **module**, **playbook** :heavy_check_mark: Mettre en œuvre Ansible ;       
:heavy_check_mark: Appliquer des changements de configuration sur un serveur;   
:heavy_check_mark: Créer vos premiers playbooks Ansible;   
 Une **collection** : une collection comprend un ensemble logique de playbooks, de rôles, de modules et de plugins.  Un **module** : un module rend abstrait une tâche. Il existe de nombreux modules fournis par Ansible. Un **rôle** : un rôle permet d’organiser les playbooks et tous les autres fichiers nécessaires (modèles, scripts, etc.) pour faciliter le partage et la réutilisation du code. Ansible centralise et automatise les tâches d'administration. Il est : Comme Ansible est "push-based", il ne conservera pas l'état de ses noeuds cibles entre chacune de ses exécutions. Au contraire, il effectuera de nouvelles vérifications d'état à chaque fois qu'il sera exécuté. On dit qu'il est sans état. Créer un fichier vide avec les droits en `0644` Exemples : Dans ce chapitre, vous allez apprendre à travailler avec Ansible. Il utilise le protocole **SSH** pour configurer à distance les clients Linux ou le protocole **WinRM** pour fonctionner avec des clients Windows. Si aucun de ces protocoles n'est disponible, il est toujours possible pour Ansible d'utiliser une API, ce qui fait d'Ansible un véritable couteau suisse de la configuration des serveurs, des postes de travail, des services dockers, des équipements réseaux, etc. (Pratiquement tout en fait). Il vous aidera à : Les **facts** : ce sont des variables globales contenant des informations à propos du système (nom de la machine, version du système, interface et configuration réseau, etc.). Les **handlers** : il sont utilisés pour provoquer un arrêt ou un redémarrage d’un service en cas de changement. L'**inventaire** : un fichier contenant les informations concernant les serveurs gérés. Le poste de gestion : la machine sur laquelle Ansible est installée. Ansible étant agentless, aucun logiciel n’est déployé sur les serveurs gérés. Les **playbooks** : un fichier simple au format yaml définissant les serveurs cibles et les tâches devant être effectuées. Les tâches (**tasks**) : une tâche est un bloc définissant une procédure à exécuter (par exemple créer un utilisateur ou un groupe, installer un paquet logiciel, etc.). Pour offrir une interface graphique à votre utilisation quotidienne d'Ansible, vous pouvez installer certains outils comme Ansible Tower (RedHat), qui n'est pas gratuit, son homologue opensource Awx, ou d'autres projets comme Jenkins et l'excellent Rundeck peuvent également être utilisés. Vous pouvez contrôler la syntaxe de votre playbook : ``` ```
$ ansible-playbook --syntax-check play.yml 
``` ```
ansible ansible_clients --become -m group -a "name=Paris" 
ansible ansible_clients --become -m group -a "name=Tokio" 
ansible ansible_clients --become -m group -a "name=NewYork" 
ansible ansible_clients --become -m user -a "name=Supervisor" 
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000" 
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000 groups=Paris"
ansible ansible_clients --become -m dnf -a "name=tree" 
ansible ansible_clients --become -m systemd -a "name=crond state=stopped" 
ansible ansible_clients --become -m copy -a "content='' dest=/tmp/test force=no mode=0644" 
ansible ansible_clients --become -m dnf -a "name=* state=latest" 
ansible ansible_clients --become -m reboot
``` déployer des applications l'automatisation, la gestion de la configuration, l'orchestration (quand plus d'un noeud cible est en jeu). provisionner (déployer une nouvelle machine virtuelle), le premier sera le **poste de gestion**, Ansible sera installé dessus. le second sera le serveur à configurer et à gérer (un autre Linux que Rocky Linux fera tout aussi bien l'affaire). 