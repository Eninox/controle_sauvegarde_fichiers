<# ---------------------------------------------------------------- #>
<# ------ CONTROLE EXECUTION DES SCRIPTS DE SAUVEGARDE XXXX --------#>
<# ---------------------------------------------------------------- #>

<# ------------------------ VARIABLES------------------------------ #>
<# MANIPULATION DATES #>
$dateJour = (Get-Date).ToString('dd/MM/yyyy HH:mm')
$dateJourAMJ = (Get-Date).ToString('yyyyMMdd_HHmm')
$date = (Get-Date).adddays(-1.5)
$dateJMA = $date.ToShortDateString()
$dateAMJ = $date.ToString('yyyyMMdd')
$dateJour1 = $date.ToString('%d')
$dateMois1 = $date.ToString('%M')
$dateMois2 = $date.ToString('MM')
$dateAnnee = $date.ToString('yyyy')

<# DOSSIERS CIBLE #>
$cheminParent = "\\chemin\destination\fichiers"
$cheminEnfant1 = $cheminParent + "\appli\*"
$cheminEnfant2 = $cheminParent + "\appli\dossierX\$dateAnnee\$dateMois1*\$dateJour1\*"
$cheminEnfant3 = $cheminParent + "\appli\dossierX\dossierY*\*"
$cheminEnfant4 = $cheminParent + "\appli\dossierX\dossierY*_$dateAMJ\*\*"
$cheminEnfant5 = $cheminParent + "\appli\*"

$dataSauvegarde = @(
    [pscustomobject]@{Nom='Appli1';     Serveur='serverX';   CheminScript='chemin\script\sauvegarde\sauvegarde1.bat';       CheminSauvegarde=$cheminEnfant1 }
    [pscustomobject]@{Nom='Appli2';     Serveur='serverX';   CheminScript='chemin\script\sauvegarde\sauvegarde2.bat';       CheminSauvegarde=$cheminEnfant2 }
    [pscustomobject]@{Nom='Appli3';     Serveur='serverX';   CheminScript='chemin\script\sauvegarde\sauvegarde3.bat';		CheminSauvegarde=$cheminEnfant3 }
    [pscustomobject]@{Nom='Appli4';    	Serveur='serverX';   CheminScript='chemin\script\sauvegarde\sauvegarde4.bat';       CheminSauvegarde=$cheminEnfant4 }
    [pscustomobject]@{Nom='Appli5';     Serveur='serverX';   CheminScript='chemin\script\sauvegarde\sauvegarde5.bat';       CheminSauvegarde=$cheminEnfant5 }
)

<# DOSSIER LOG ET EPURATION + 1 MOIS #>
$logDossier = "chemin\destination\log\"
$dateLimite = (Get-Date).AddMonths(-1)
$logFichiers = Get-ChildItem -Path $logDossier -File

foreach ($fichier in $logFichiers) {
    if ($fichier.LastWriteTime -lt $dateLimite -and $fichier.FullName -eq "*.log") {
        Remove-Item -Path $fichier.FullName -Force
    }
}

<# --------------------------- FONCTIONS -------------------------- #>
<# ENVOI MAIL #>
function Send-Email-Tech {
    param (
        $DestinataireMail,
        $Contenu
    )
$sujetMail = "Compte rendu sauvegardes XXXX au $dateJour"
$messageMail = @"
<html>
    <head></head>
    <body style="font-family:Calibri">
        <h2>Compte rendu des sauvegardes XXXX au $dateJour</h2>
        <p>$Contenu</p>
        <br><br>
        <p><em>Ne pas repondre, cet email est transmis automatiquement</em></p>
    </body>
</html>
"@

Send-MailMessage `
		-Encoding UTF8 `
        -From 'ne-pas-repondre@domain_mail' `
        -To $DestinataireMail `
        -Subject $sujetMail `
        -BodyAsHtml `
        -Body $messageMail `
        -SmtpServer 'ServerX' `
}

<# ------------------------- DEBUT SCRIPT ------------------------- #>

$logResultat = @("`n-------------------------------------------------------------------------------------------------------------------------------------------------------------------- `
Lancement controle sauvegardes XXXX le $dateJour `
--------------------------------------------------------------------------------------------------------------------------------------------------------------------")

foreach ($data in $dataSauvegarde) {
    try {
        <# RECUEIL ET ORGANISATION DES DONNEES DES FICHIERS CIBLE #>
        $fichierDateModif = Get-ItemPropertyValue -Path $data.CheminSauvegarde -Name LastWriteTime | Select-Object | Sort-Object -Descending
        $infoDossier = Get-ChildItem -Path $data.CheminSauvegarde | Measure-Object -Property Length -Sum
        $tailleDossier = $infoDossier.sum / 1MB
        $tailleDossierArrondi = "{0:N2}" -f $tailleDossier
        
        <# LOG ET MAIL SI DERNIER FICHIER ENREGISTRE SUPERIEUR A DATE REFERENCE (SUCCES) #>
        if ($fichierDateModif[0] -ge $date) {
            $logResultat += 
            "`n Nom Sauvegarde : `t" + $data.Nom + `
            "`n Serveur : `t`t" + $data.Serveur + `
            "`n Chemin script : `t" + $data.CheminScript + `
            "`n Chemin Sauvegarde : `t" + $data.CheminSauvegarde + `
            "`n Dernier fichier : `t" + $fichierDateModif[0].ToString('dd/MM/yyyy HH:mm') + `
            "`n Nb fichiers : `t`t" + $fichierDateModif.Count + " fichiers (" + $tailleDossierArrondi + "Mo)" + `
            "`n Resultat : `t`tSUCCES `n -----------------------------------------"

            $mailResultat += 
            "<ul><li><b>Nom Sauvegarde : " + $data.Nom + "</b></li>" + `
            "<li> Serveur : " + $data.Serveur + "</li>" + `
            "<li>Chemin script : " + $data.CheminScript + "</li>" + `
            "<li>Chemin Sauvegarde : " + $data.CheminSauvegarde + "</li>" + `
            "<li>Dernier fichier : " + $fichierDateModif[0].ToString('dd/MM/yyyy HH:mm') + "</li>" + `
            "<li>Nb fichiers : " + $fichierDateModif.Count + " fichiers (" + $tailleDossierArrondi + "Mo)" + "</li>" + `
            "<li> Resultat : <b style='color:green'>SUCCES</b></li></ul>" + `
            "-----------------------------------------"
        <# SINON: LOG ET MAIL SI DERNIER FICHIER ENREGISTRE INFERIEUR A DATE REFERENCE (ANOMALIE) #>
        } else {
            $logResultat += 
            "`n Nom Sauvegarde : `t" + $data.Nom + `
            "`n Serveur : `t`t" + $data.Serveur + `
            "`n Chemin script : `t" + $data.CheminScript + `
            "`n Chemin Sauvegarde : `t" + $data.CheminSauvegarde + `
            "`n Resultat : `t`tANOMALIE - dernier enregistrement au " + $fichierDateModif[0].ToString('dd/MM/yyyy HH:mm') + `
            "`n -----------------------------------------"
            
            $mailResultat += 
            "<ul><li><b>Nom Sauvegarde : " + $data.Nom + "</b></li>" + `
            "<li>Serveur : " + $data.Serveur + "</li>" + `
            "<li>Chemin script : " + $data.CheminScript + "</li>" + `
            "<li>Chemin Sauvegarde : " + $data.CheminSauvegarde + "</li>" + `
            "<li>Resultat : <b style='color:red'>ANOMALIE</b> - dernier enregistrement au " + $fichierDateModif[0].ToString('dd/MM/yyyy HH:mm') + "</li></ul>" + `
            "-----------------------------------------"
        }
    } catch {
        <# SI ERREUR: LOG ET MAIL SI CHEMIN DE FICHIER NON TROUVE (ANOMALIE) #>
            $logResultat += 
            "`n Nom Sauvegarde : `t" + $data.Nom + `
            "`n Serveur : `t`t" + $data.Serveur + `
            "`n Chemin script : `t" + $data.CheminScript + `
            "`n Chemin Sauvegarde : `t" + $data.CheminSauvegarde + `
            "`n Resultat : `t`tANOMALIE - chemin de sauvegarde introuvable
            `n -----------------------------------------"

            $mailResultat += 
            "<ul><li><b>Nom Sauvegarde : " + $data.Nom + "</b></li>" + `
            "<li>Serveur : " + $data.Serveur + "</li>" + `
            "<li>Chemin script : " + $data.CheminScript + "</li>" + `
            "<li>Chemin Sauvegarde : " + $data.CheminSauvegarde + "</li>" + `
            "<li>Resultat : <b style='color:red'>ANOMALIE</b> - chemin de sauvegarde introuvable" + "</li></ul>" + `
            "-----------------------------------------"
    }
}

<# ENREGISTREMENT LOG #>
Add-Content "$logDossier\ctrl_sauv_$dateJourAMJ.log" -Value $logResultat

<# ENVOI MAIL SI ANOMALIE #>
if ($logResultat -match "ANOMALIE") {
    Send-Email-Tech -DestinataireMail "personne1@domain_mail" -Contenu $mailResultat
}

<# EPURATION VARIABLES #>
Clear-Variable "logResultat"
Clear-Variable "mailResultat"

Exit

<# ------------------------- FIN SCRIPT --------------------------- #>