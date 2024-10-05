# controle_sauvegarde_fichiers
Script de contrôle multi sauvegardes avec analyse des fichiers finaux, log, alerte mail en cas d'anomalie

  ### Elements préparatoires
1. Définition des variables de type "date" nécessaires pour traiter toutes les sauvegardes quotidiennes
2. Définition des dossiers cible (pour contrôle des fichiers finaux) avec les chemins adéquats
3. Purge du dossier log fichiers plus d'un mois
4. Définition fonction d'alerte mail

  ### Début script
6. Reporting et composition d'un tableau avec les fichiers présents
* Si fichier enregistré postérieur à la date cible de rétention (ex - 1,5 jours) -> SUCCES
* Si fichier antérieur -> ANOMALIE
* Si chemin du dossier absent -> ANOMALIE
7. Log des résultats en fonction des conditions
8. Envoi d'un mail récapitulatif (au choix, envoi systématique ou seulement en cas d'anomalie) <center>
 ![alt text](https://github.com/Eninox/controle_sauvegarde_fichiers/blob/main/mail_exemple.png) </center> 
