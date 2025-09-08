# Reporting Trimestriel du Risque de Crédit (SAS)

Ce projet a pour but d’automatiser le reporting trimestriel sur le risque de crédit à l’aide de SAS.
Il permet de transformer des données brutes (encours de crédit, statuts clients, défauts) en un reporting structuré, agrégé et fiable, destiné à la direction et aux instances de gouvernance.

L’automatisation proposée réduit le risque d’erreurs manuelles, garantit la cohérence des calculs, et facilite la prise de décision grâce à des indicateurs clairs et standardisés.

## Fonctionnalités

- Importer les données de risque de crédit depuis CSV  
- Créer des indicateurs trimestriels (`2025-T1`, `2025-T2`, …)  
- Calculer les provisions (30 % de l’encours en défaut)  
- Produire un reporting agrégé par trimestre et par segment de risque  
- Exporter les résultats dans Excel pour les parties prenantes métiers  
- Intégrer des contrôles qualité (`PROC MEANS`, `PROC FREQ`)  

## Technologies
- SAS Studio
