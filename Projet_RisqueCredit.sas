
/****************************************************************************************************************************************/
/*                                                                                                                                       */
/*                                        Reporting sur les expositions et défauts de crédit                                                      */
/*                                                      Arsène DJIROUE                                                                                                                                    */
/*****************************************************************************************************************************************/

/* Creation bibliothèque SAS */

LIBNAME P1 "/home/u64069964/P1";

/* Importation de la base de donnée */

PROC IMPORT DATAFILE= "/home/u64069964/P1/credit_risk_data.xlsx"
			out=P1.credit_risk_data
			dbms=xlsx
			replace;
			getnames=YES;
RUN;

/* J'affiche la base de données */

PROC CONTENTS DATA=P1.credit_risk_data;
RUN;

PROC PRINT DATA=P1.credit_risk_data;
RUN;


data P1.credit_risk_data;
    set P1.credit_risk_data;

    /* Ici j'écrase complètement la colonne provision existante */
    /* Si le client est en défaut, provision = 30% de l’encours, sinon 0 */
   
    if statut_client = "En défaut" then provision = encours * 0.3;
    else provision = 0;

    /* Je crée l'année, le numéro du trimestre et l'étiquette année_trimestre */
   
    annee = year(date_ouverture);
    numero_trimestre = qtr(date_ouverture);
    annee_trimestre = cats(annee, 'Q', numero_trimestre);
run;


PROC PRINT DATA=P1.credit_risk_data (obs=10);
RUN;

/* Je supprimer les colonnnes */

data P1.credit_risk_data;
    set P1.credit_risk_data;
    drop annee numero_trimestre annee_trimestre date_clean ;
Run;
    

PROC PRINT DATA=P1.credit_risk_data (obs=10);
RUN;

PROC CONTENTS DATA=P1.credit_risk_data (obs=10);
RUN;

/* Je convertis ta variable provision en numérique */

data P1.credit_risk_data;
    set P1.credit_risk_data;
    provision_num = input(provision, ?? best12.);
run;


data P1.credit_risk_data;
    set P1.credit_risk_data;

    /* Je transformer en date SAS (partie date uniquement) */
   
    date_ouverture_date = datepart(date_ouverture);

    /* Je crée annee_mois sous forme AAAA-MM */
    /*annee_mois = put(date_ouverture_date, yymmn6.);

    /* annee_trimestre sous forme AAAA-Tx */
   
    annee_trimestre = cats(year(date_ouverture_date), '-T', qtr(date_ouverture_date));
run;


/*  Je crée une variable numérique pour provision */

data P1.credit_risk_data;
    set P1.credit_risk_data;
    
    /* Conversion de la variable texte 'provision' en numérique */
   
    provision_num = input(provision, ?? best12.);
run;

/* Je créer annee_trimestre */

data P1.credit_risk_data;
    set P1.credit_risk_data;

    /* Extraire la date (partie jour uniquement) à partir du datetime */
   
    date_ouverture_date = datepart(date_ouverture);

    /* Création de la variable annee_trimestre sous forme '2025-T1' par ex. */
   
    annee_trimestre = cats(year(date_ouverture_date), '-T', qtr(date_ouverture_date));
run;

/* Reporting trimestriel */


proc print data=P1.reporting_trimestriel (obs=10);
run;

data P1.credit_risk_data_num2;
    set P1.credit_risk_data;
    provision_num = input(provision, best32.);
run;


proc sql;
    create table P1.reporting_trimestriel as
    select 
        annee_trimestre,
        segment_risque,
        count(*) as nb_dossiers,
        sum(encours) as total_encours,
        sum(provision_num) as total_provisions,
        sum(case when statut_client='En défaut' then 1 else 0 end) as nb_defauts
    from P1.credit_risk_data_num2
    group by annee_trimestre, segment_risque
    order by annee_trimestre, segment_risque;
quit;

/* J'exporte le reporting agrégé en fichier Excel */

proc export data=P1.reporting_trimestriel
    outfile="/home/u64069964/reporting_trimestriel.xlsx"
    dbms=xlsx
    replace;
run;


/* Je fais un contrôle qualité simple : vérifier le total des encours et nombre de défauts */

/* Je convertis la provision en variable numerique */

data P1.credit_risk_data;
    set P1.credit_risk_data;
    provision_num= input(provision, best32.);
run;


proc means data=P1.credit_risk_data sum nmiss;
    var encours provision_num;
run;


proc freq data=P1.credit_risk_data;
    tables statut_client segment_risque type_produit / missing;
run;

/* Fin du script Reporting automatisé sous SAS*/

title "Reporting automatisé terminé avec succès";


/*********************************************************************************************************/
/* Ici , j'apporte des correctifs sur le premier Scrip */



LIBNAME P1 "/home/u64069964/P1";

PROC IMPORT DATAFILE= "/home/u64069964/P1/credit_risk_data.xlsx"
            out=P1.credit_risk_data
            dbms=xlsx
            replace;
            getnames=YES;
RUN;

/* je préparation des variables date, provision et numérique */

data P1.credit_risk_data;
    set P1.credit_risk_data;

    date_ouverture_date = datepart(date_ouverture);
    annee_trimestre = cats(year(date_ouverture_date), '-T', qtr(date_ouverture_date));

    if statut_client = "En défaut" then provision = encours * 0.3;
    else provision = 0;

    provision_num = input(provision, best32.);
run;


/* Reporting trimestriel agrégé */

proc sql;
    create table P1.reporting_trimestriel as
    select 
        annee_trimestre,
        segment_risque,
        count(*) as nb_dossiers,
        sum(encours) as total_encours,
        sum(provision_num) as total_provisions,
        sum(case when statut_client='En défaut' then 1 else 0 end) as nb_defauts
    from P1.credit_risk_data
    group by annee_trimestre, segment_risque
    order by annee_trimestre, segment_risque;
quit;

/* J'exporte le reporting */

proc export data=P1.reporting_trimestriel
    outfile="/home/u64069964/reporting_trimestriel.xlsx"
    dbms=xlsx
    replace;
run;

/* Je fais un contrôle qualité */

proc means data=P1.credit_risk_data sum nmiss;
    var encours provision_num;
run;

proc freq data=P1.credit_risk_data;
    tables statut_client segment_risque type_produit / missing;
run;

title "Reporting automatisé terminé avec succès";

outfile="/home/u64069964/reporting_trimestriel.xlsx";


proc options option=work;
run;

