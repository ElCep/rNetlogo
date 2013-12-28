#auteur : Etienne DELAY (GEOLAB, Université de Limoges)
#script pour utiliser des données SIG dans NetLogo par l'intermédiaire de R
#Largement inspiré par l'atelier organisé a supAgro avec F. Vinatier en Novembre 2013
#Ici pour intégrer des données de banyuls-sur-mer dans un modèle netlogo

rm(list=ls(all=TRUE)) 

#Chargement des LIBRAIRIES
library("raster")
library("maptools")
library("rgdal")
library("RNetLogo")

# Chargement du répertoire dans lequel se trouvent les données
setwd("~/Documents/Donnee_carto/Banyuls/")

##préparation pour RNetLogo
# Chemin.datas="CG66/DTMBanyulsEPSG2154/"
Chemin.Netlogo="/opt/netlogo" #ici on indique le chemin vers le dossier netlogo (ici sur archlinux)
Chemin.Model="/home/delaye/Dropbox/netlogo/BaWork/"


# ______________________________________________________________________________________ 
# |                                                                                                                                                                                                      |
# |                    Chargement des données SIG                                                                                                                          |
# ______________________________________________________________________________________ 
# Chargement des étendues des trois zones d’étude et du système de projection
proj=CRS("+init=epsg:2154")    # projection du projet (lambert 93/RGF93)
parcelles=readShapePoly("MyCreate/Cadastre_Communes_AOC_L93/JointureCadastreL93_AOC(2)/joined.shp")  #lecture du fichier shape

projection(parcelles)<-proj   # attribution de la projection RGF 93 au fichier buffer
# Chargement du modèle numérique de terrain
MNT<-readGDAL("CG66/DTMBanyulsEPSG2154/DTM10m.tif")  #lecture du MNT (modele numerique de terrain)
slope<-terrain(MNT,opt='slope',unit='degrees',neighbors=8)
temperature<-readGDAL("MyCreate/")
projection(MNT)<-proj        # attribution de la projection RGF 93 au MNT
projection(slope)<-proj
MNT=raster(MNT)             # transformation en format raster (lisible par package raster)
names(MNT)="MNT"            # attribution du nom du raster

# ______________________________________________________________________________________ 
# |                                                                                                                                                                                                      |
# |                    Découpage agrégation rasterisation                                                             |
# ______________________________________________________________________________________ 
MNT2=crop(MNT,parcelles) 
#MNT=aggregate(MNT,10)

# ______________________________________________________________________________________ 
# |                                                                                                                                                                                                      |
# |                    Export des cartes pour pouvoir les charger avec Netlogo
# |                    Pour le moment les données sont préparer et organiser pour ensuite
# |                    venir être charger dans Netlogo par l'intermédiaire de R
# |                    Netlogo charge du ascii donc les données sont écrite en acsii
# ______________________________________________________________________________________ 

writeRaster(MNT2,"/home/delaye/Dropbox/netlogo/BaWork/ASCII-DATA/mnt",format="ascii",overwrite=T)

# ______________________________________________________________________________________ 
# |                                                                                                                                                                                                      |
# |                   LANCEMENT DE NETLOGO
# |                   C'est ici que les choses intéressante commence!
# |                   on va charger les données préparer précedement dans netlogo
# ______________________________________________________________________________________ 

NLStart(nl.path=Chemin.Netlogo,nl.version=5,gui=T) # lancement de Netlogo gui peut être T ou F pour afficher ou non le gui
NLLoadModel(paste(Chemin.Model,"bear.nlogo",sep="")) # chargement du modèle

NLCommand(paste("set xmax",dim(MNT)[2]))
NLCommand(paste("set ymax",dim(MNT)[1]))

NLCommand("setup")
#NLCommand("setup")

cpt=0
while(cpt <= 100)
{
  cpt=cpt+1
  NLCommand("go")
}

#pour fermer l'instance netlogo
NLQuit()
