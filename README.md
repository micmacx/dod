# Tuto 2020 : Installation d'un serveur Day of Defeat: Source + Clonage des Plugins nécéssaires pour le faire fonctionner avec les bots Rcbot2 hypercheatés.

Mon install a été réalisé sur une distrib debian sans interface graphique

# Liste des plugins :
```
01 "Anti-Flood" (1.10.0.6490) by AlliedModders LLC
02 "DoDS Swapteams" (1.0.600) by <eVa>Dog
03 "TK Manager" (1.11) by Stevo.TVR
04 "DoD HitInfo" (1.1) by FeuerSturm
05 "Basic Votes" (1.10.0.6490) by AlliedModders LLC
06 "Sound Commands" (1.10.0.6490) by AlliedModders LLC
07 "Basic Chat" (1.10.0.6490) by AlliedModders LLC
08 "Dog's Prop Bonus Round" (1.13) by <eVa>Dog (edited by: retsam)
09 "Client Preferences" (1.10.0.6490) by AlliedModders LLC
10 "dod welcome server" (2.0) by vintage by dodsplugins.net Team
11 "DoD SpawnProtect Source" (1.5.1) by FeuerSturm
12 "Basic Ban Commands" (1.10.0.6490) by AlliedModders LLC
13 "Dod:Source GoFlag" (1.1) by BenSib
14 "Anticamp" (2.1.7) by Misery
15 "Basic Commands" (1.10.0.6490) by AlliedModders LLC
16 "Admin Menu" (1.10.0.6490) by AlliedModders LLC
17 "DoD:S Capture Bonus" (1.2.0) by BackAgain
18 "Cheater Buster Tools" (1.2) by KawMAN
19 "DOD:S Parachutes" (3.0) by orig. Script from SWAT_88, Vintage, Darkranger
20 "Player Commands" (1.10.0.6490) by AlliedModders LLC
21 "DoD BlockExploits" (1.8.1) by FeuerSturm + darkranger, vintage
22 "UNSCOPED LITE" (1.6.7 Lite) by Misery, Lite by n0n
23 "Quake Sounds v3" (3.5.0) by Spartan_C001
24 "DOD Laser Aim" (1.5DODS) by Darkranger(for DODS), original fom Leonardo(for CSS)
25 "Admin Sounds" (1.2.2) by cadav0r, dalto, o_O.Uberman.O_o, |HS|Jesus
26 "DOD:S Balancer" (1.0) by AMP
27 "MapChooser" (1.10.0.6490) by AlliedModders LLC
28 "Admin File Reader" (1.10.0.6490) by AlliedModders LLC
29 "Fun Votes" (1.10.0.6490) by AlliedModders LLC
30 "Admin Help" (1.10.0.6490) by AlliedModders LLC
31 "HP Regeneration" (1.0) by MaTTe
32 "Basic Info Triggers" (1.10.0.6490) by AlliedModders LLC
33 "Basic Comm Control" (1.10.0.6490) by AlliedModders LLC
34 "RocketBattle" (1.0) by BlackSun
35 "Fun Commands" (1.10.0.6490) by AlliedModders LLC
36 "DoD Pistols" (1.0.201) by <eVa>Dog
37 "Required Cappers Changer" (1.0.1) by Knagg0
38 "Rock The Vote" (1.10.0.6490) by AlliedModders LLC
39 "RandomCycle" (1.10.0.6490) by AlliedModders LLC
40 "DoD:S Class Manager" (1.0) by Ben
```
# Tuto : Installation d'un serveur Day of Defeat : Source

Pour rappel, l'installation a été réalisé sur une distrib debian.

Première chose à savoir :
```
Appid day of defeat source : 232290
```

# Tuto
```
adduser srvdod
su srvdod
mkdir /home/srvdod/srcds/
mkdir /home/srvdod/srcds/dod_s
cd /home/srvdod/srcds/dod_s/
git clone git@github.com:micmacx/dod.git
cd ..
wget http://media.steampowered.com/client/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
chmod +x steamcmd.sh
./steamcmd.sh
git reset --hard
```

Une console propriétaire steam va se lancer ou un shell, c'est comme vous voulez, dedans il faut taper :
```
login anonymous
force_install_dir /home/srvdod/srcds/dod_s/
app_update 232290 validate
app_update 232290 validate
exit (si ok)
```
Afin de vérifier que l'utilitaire a bien télécharger tous les fichiers,on lance 2 fois la même commande, si c'est ok : “Success! App '232290' fully installed.”

Voilà c'est fait, la base du serveur est installée.


# Trouver son steamid et ajouter le bind pour afficher le menu admin :

Dans l'interface "mes jeux"

Clic droit sur Day of Defeat : Source-->Propriétés

Définir les options de lancement

ajouter : "-console"

Lancer dod en se connectant à un serveur

appuyer sur escape

dans la console taper status
```
bind "b" sm_admin 
```
copier son steamdid

aller sur le site https://steamidfinder.com/lookup/U%3A1%3A37484034/

# Maintenant il suffit simplement de configurer quelques fichiers :
```
~/srcds/dod_s/dod/cfg/server.cfg //Modifier le nom du serveur, le lien du fast download...
~/srcds/dod_s/dod/cfg/mapcycle.txt  //Mettez le listing de toutes vos maps.
~/srcds/dod_s/dod/addons/sourcemod/configs/admins_simple.ini //mettez votre steamid pour pouvoir accéder au menu administration du serveur.
~/srcds/dod_s/dod/sound/ //Mettez vos fichiers sons dans ce répertoire
~/srcds/dod_s/dod/addons/sourcemod/configs/soundslist.cfg  //Modifier ce fichier pour y mettre vos sons personalisés. Il faut enlever les fichiers son commençant par music*.*
```
# Pour Lancer le serveur :
```
cd ~/srcds/dod_s/ 
./srcds_run -game dod -port 27015 +maxplayers 20 +map dod_avalanche
```
si vous ne modifiez pas la crontab, sinon pas besoin, le serveur se lancera tout seul.

# Trouver les ports à ouvrir, rediriger :
Lancer le serveur de jeu.
```
Netstat -uta
```
Chercher les ports en rapport avec le jeu.

# Lancer le serveur automatiquement et le relancer si il se coupe
copier le fichier dod et test_dod dans un répertoire path

afficher les répertoires path :
```
echo $PATH
```
puis editer la crontab
```
crontab -e
```
ajouter la ligne
```
* * * * * /usr/local/bin/test_dod
```
Sauvegarder et c'est ok, toutes les minutes il y aura un test éffectué qui lancera ou relancera le serveur si il n'est pas en marche.
