# res_hopital — Guide fonctionnel

## Navigation générale
- **Sidebar** : accès principal aux modules.
- **AppBar** : actions contextuelles (recherche globale, notifications).
- **Body** : contenu principal avec onglets selon l’écran.
- **Bottom Bar** : statut temps réel et alertes urgentes.

## Modules clés
1. **Tableau de bord** : chiffres clés, graphiques, alertes critiques, agenda.
2. **Patients** : registre, filtres avancés, actions en lot, dossier patient en onglets.
3. **Personnel médical** : profils, planning, disponibilités, statistiques.
4. **Chambres & lits** : cartographie, statut temps réel, maintenance, tarification.
5. **Consultations & RDV** : agenda multi-vues, prise de RDV, dossier consultation.
6. **Examens & laboratoire** : workflow demande → résultats, templates et validations.
7. **Pharmacie & stocks** : inventaire, traçabilité, dispensation, approvisionnements.
8. **Interventions** : planning opératoire, équipe, matériel, compte-rendu.
9. **Urgences** : tri, workflow de prise en charge, orientation.
10. **Facturation & assurances** : factures, télétransmission, encaissements.
11. **Comptabilité** : journaux, états financiers, analyses par service.
12. **Reporting** : KPI qualité/finance/RH, rapports exportables.
13. **Paramètres** : structure, tarifs, utilisateurs, audit & sauvegardes.

## Architecture & données
Application **Flutter Desktop** en **mode offline** avec **SQLite**.  
Tables principales : `utilisateurs`, `patients`, `personnel_medical`, `consultations`,
`hospitalisations`, `prescriptions_medicaments`, `examens_analyses`,
`stock_medicaments`, `facturation_paiements`, `rapports_statistiques`, `paramet`.

## Design & UX
- **Material 3** avec palette médicale (bleu/vert/blanc).
- **Mode clair/sombre**, accessibilité renforcée, navigation clavier.
- Composants réutilisables : DataTables, formulaires validés, charts, calendriers.

## Workflows types (exemples)
- **Admission urgence** : tri → consultation → examens → lit → hospitalisation.
- **Consultation programmée** : RDV → accueil → acte → facturation → suivi.
- **Dispensation** : prescription → validation → stock → délivrance → MAJ stock.

## Sécurité & conformité
Traçabilité complète, sauvegardes chiffrées, droits d’accès par rôle, conformité RGPD
et secret médical.



### Application de Gestion Hospitalière Complète
Flutter Desktop + SQLite (Mode Offline)
 
🏗️ Architecture Technique
Base de données SQLite
-- Tables principales
- utilisateurs (gestion des rôles et accès)
- patients (informations médicales et personnelles)
- personnel_medical (médecins, infirmiers, techniciens)
- departements (services hospitaliers)
- chambres_lits (gestion des hébergements)
- consultations (rendez-vous et examens)
- hospitalisations (admissions et sorties)
- prescriptions_medicaments
- examens_analyses (laboratoire, radiologie)
- interventions_chirurgicales
- stock_medicaments
- stock_materiels
- facturation_paiements
- assurances_mutuelles
- fournisseurs
- approvisionnements
- comptabilite_hospitaliere
- rapports_statistiques
- parametres_hopital
Structure de navigation
•	Sidebar : Navigation principale entre modules
•	AppBar : Barre d'outils contextuelle avec actions rapides
•	Body : Zone de contenu principal avec onglets si nécessaire
•	Bottom Bar : Informations de statut et notifications urgentes
 
📱 Modules & Écrans Détaillés
🔹 1. TABLEAU DE BORD
Écran principal avec widgets synthétiques
Widgets dashboard :
•	Chiffres clés du jour : Patients hospitalisés, consultations, urgences, disponibilité lits
•	Graphiques : Évolution admissions sur 30 jours, taux d'occupation par service
•	Alertes critiques : Patients en état critique, stocks faibles, équipements en maintenance
•	Indicateurs de performance : Temps d'attente moyen, taux de satisfaction, ratio personnel/patients
•	Agenda du jour : Interventions programmées, consultations, réunions
Actions rapides :
•	Bouton FAB : "Nouvelle admission"
•	Barre de recherche globale (patient/personnel/chambre)
•	Notifications système (urgences, alertes médicales)
•	Statut temps réel des services
 
🔹 2. GESTION DES PATIENTS
Écran principal : Registre des patients
•	DataTable avec colonnes : Photo, N° dossier, Nom complet, Âge/Sexe, Statut, Chambre, Médecin traitant, Actions
•	Filtres : Par service, statut (hospitalisé/externe/sorti), type assurance, période admission
•	Recherche avancée : Nom, N° dossier, téléphone, N° assurance, diagnostic
•	Actions en lot : Transferts de service, génération attestations, exports statistiques
Écran détail patient (Dossier médical complet)
Tabs:
├── 📋 Informations personnelles
│   ├── État civil (nom, date naissance, adresse, contacts)
│   ├── Photo d'identité
│   ├── Pièces d'identité (CNI, passeport)
│   ├── Contacts d'urgence (famille, tuteur)
│   └── Groupe sanguin, allergies connues
│
├── 🏥 Dossier médical
│   ├── Historique des consultations
│   ├── Diagnostics et pathologies
│   ├── Hospitalisations antérieures
│   ├── Interventions chirurgicales
│   ├── Allergies et contre-indications
│   └── Antécédents familiaux
│
├── 💊 Prescriptions & Traitements
│   ├── Ordonnances en cours
│   ├── Historique médicamenteux
│   ├── Posologie et administration
│   ├── Effets secondaires signalés
│   └── Gestion des renouvellements
│
├── 🔬 Examens & Analyses
│   ├── Résultats laboratoire
│   ├── Imagerie médicale (radios, scanners, IRM)
│   ├── Examens spécialisés
│   ├── Bilans de santé
│   └── Évolution des constantes
│
├── 💰 Facturation & Assurance
│   ├── Couverture assurance/mutuelle
│   ├── Factures émises
│   ├── Paiements effectués
│   ├── Reste à charge patient
│   └── Historique remboursements
│
└── 📄 Documents & Attestations
    ├── Certificats médicaux
    ├── Attestations d'hospitalisation
    ├── Comptes rendus opératoires
    ├── Ordonnances de sortie
    └── Documents administratifs
Formulaire nouvelle admission
•	Wizard en étapes : Identification → État de santé → Assurance → Attribution chambre
•	Validation temps réel des champs
•	Vérification automatique de l'éligibilité assurance
•	Génération automatique du numéro de dossier médical
•	Assignation intelligente de chambre selon pathologie et disponibilité
 
🔹 3. GESTION DU PERSONNEL MÉDICAL
Écran équipe médicale
•	Cards avec photo, nom, spécialité, service, statut (disponible/en consultation/en congé)
•	Filtres : Par service, spécialité, grade, statut
•	Vue planning : Gardes, permanences, congés
•	Actions : Modifier planning, affecter patients, gérer absences
Écran détail personnel
Tabs:
├── 👤 Profil professionnel
│   ├── Informations personnelles
│   ├── Qualification et diplômes
│   ├── Spécialités et certifications
│   ├── Numéro d'ordre professionnel
│   └── Date d'embauche, contrat
│
├── 📅 Planning & Disponibilités
│   ├── Horaires de travail
│   ├── Gardes programmées
│   ├── Congés et absences
│   ├── Consultations planifiées
│   └── Interventions assignées
│
├── 👥 Patients assignés
│   ├── Liste des patients en charge
│   ├── Consultations du jour
│   ├── Suivis en cours
│   └── Historique interventions
│
└── 📊 Statistiques & Performance
    ├── Nombre de consultations
    ├── Taux de satisfaction patients
    ├── Interventions réalisées
    └── Indicateurs de qualité
Planning des gardes
•	Calendrier interactif avec drag & drop
•	Gestion automatique des rotations
•	Alertes conflits d'horaires
•	Notification automatique au personnel
 
🔹 4. GESTION DES CHAMBRES & LITS
Cartographie hospitalière
•	Vue par étage/service avec plan interactif
•	Statut temps réel : Occupé/Libre/En nettoyage/En maintenance
•	Filtres : Par type (standard/VIP/soins intensifs), disponibilité, équipements
•	Actions : Affecter patient, libérer, marquer pour nettoyage
Écran détail chambre
Informations:
├── 🛏️ Configuration
│   ├── Numéro chambre, étage, aile
│   ├── Type (individuelle/double/VIP/USI)
│   ├── Nombre de lits
│   └── Équipements disponibles
│
├── 👤 Occupation actuelle
│   ├── Patient(s) occupant(s)
│   ├── Date d'admission
│   ├── Pathologie
│   └── Médecin référent
│
├── 🧹 Maintenance & Entretien
│   ├── Statut nettoyage
│   ├── Dernier entretien
│   ├── Équipements à réparer
│   └── Historique maintenance
│
└── 💰 Tarification
    ├── Tarif journalier
    ├── Suppléments (TV, climatisation)
    └── Facturation en cours
Tableau d'occupation
•	Taux d'occupation global et par service
•	Prévisions d'occupation basées sur les admissions programmées
•	Historique des mouvements (admissions/sorties)
•	Optimisation de l'allocation des chambres
 
🔹 5. CONSULTATIONS & RENDEZ-VOUS
Agenda médical
•	Vue calendrier : Jour/Semaine/Mois
•	Filtres : Par médecin, service, type consultation
•	Statuts : Programmé/En cours/Terminé/Annulé/Non présenté
•	Actions : Créer RDV, modifier, annuler, reprogrammer
Écran prise de rendez-vous
•	Sélection médecin avec disponibilités en temps réel
•	Motif de consultation (urgence/suivi/première visite)
•	Vérification conflits d'horaires
•	Confirmation automatique par SMS/Email
•	Rappels automatiques avant RDV
Écran consultation
Dossier consultation:
├── 📝 Anamnèse
│   ├── Motif de consultation
│   ├── Symptômes décrits
│   ├── Historique maladie actuelle
│   └── Questions au patient
│
├── 🔍 Examen clinique
│   ├── Constantes vitales (tension, température, pouls)
│   ├── Examen physique
│   ├── Observations du médecin
│   └── Photos/vidéos médicales
│
├── 🏥 Diagnostic
│   ├── Diagnostic principal
│   ├── Diagnostics secondaires
│   ├── Classification CIM-10
│   └── Degré de gravité
│
├── 💊 Prescription
│   ├── Médicaments prescrits
│   ├── Examens complémentaires
│   ├── Soins à domicile
│   └── Restrictions/recommandations
│
└── 📋 Suivi
    ├── Date prochain RDV
    ├── Contrôles à effectuer
    ├── Hospitalisation si nécessaire
    └── Orientation vers spécialiste
 
🔹 6. EXAMENS & LABORATOIRE
Écran gestion examens
•	Liste demandes d'examens en attente/en cours/terminés
•	Filtres : Par type (labo/radio/scanner/IRM), priorité, date
•	Workflow : Demande → Réalisation → Saisie résultats → Validation → Transmission
•	Actions : Programmer examen, saisir résultats, valider, imprimer
Types d'examens
Catégories:
├── 🔬 Laboratoire
│   ├── Hématologie (NFS, VS, CRP)
│   ├── Biochimie (glycémie, créatinine, urée)
│   ├── Sérologie (VIH, hépatites, COVID)
│   ├── Bactériologie (ECBU, hémocultures)
│   └── Parasitologie
│
├── 📡 Imagerie médicale
│   ├── Radiologie standard
│   ├── Échographie
│   ├── Scanner/TDM
│   ├── IRM
│   └── Mammographie
│
├── ⚡ Explorations fonctionnelles
│   ├── ECG/Holter
│   ├── Échographie cardiaque
│   ├── EEG
│   ├── Spirométrie
│   └── Endoscopies
│
└── 🧬 Examens spécialisés
    ├── Anatomo-pathologie
    ├── Génétique
    ├── Médecine nucléaire
    └── Biopsies
Saisie résultats
•	Templates par type d'examen
•	Valeurs de référence automatiques
•	Alertes sur valeurs anormales
•	Validation par biologiste/radiologue
•	Transmission automatique au médecin prescripteur
 
🔹 7. PHARMACIE & GESTION DES STOCKS
Stock médicaments
•	Inventaire temps réel avec alertes stocks faibles
•	Catégories : Médicaments/Consommables/Dispositifs médicaux
•	Filtres : Par DCI, laboratoire, classe thérapeutique, péremption
•	Traçabilité complète : Entrées/Sorties/Péremptions/Retours
Écran détail médicament
Fiche médicament:
├── 📦 Informations produit
│   ├── DCI et nom commercial
│   ├── Forme galénique, dosage
│   ├── Laboratoire fabricant
│   ├── Code-barres/AMM
│   └── Conservation (température, lumière)
│
├── 📊 État des stocks
│   ├── Quantité disponible
│   ├── Stock minimum/maximum
│   ├── Valeur totale stock
│   ├── Emplacement stockage
│   └── Dates de péremption
│
├── 📈 Mouvements
│   ├── Historique entrées/sorties
│   ├── Consommation moyenne
│   ├── Prévisions besoins
│   └── Fournisseurs habituels
│
└── 💰 Tarification
    ├── Prix d'achat unitaire
    ├── Prix de vente patient
    ├── Remboursement assurance
    └── Marge appliquée
Dispensation
•	Lecture code-barres ordonnance/carte patient
•	Vérification automatique ordonnance valide
•	Contrôle interactions médicamenteuses
•	Édition étiquettes posologie
•	Mise à jour automatique stock
Gestion approvisionnements
•	Commandes automatiques selon seuils
•	Suivi fournisseurs et délais livraison
•	Réception marchandises avec contrôle qualité
•	Gestion périmés avec alertes anticipées
 
🔹 8. INTERVENTIONS CHIRURGICALES
Planning opératoire
•	Calendrier salles d'opération
•	Programmation interventions avec équipe complète
•	Vérification disponibilité : Chirurgien/Anesthésiste/Infirmiers/Salle/Matériel
•	Gestion priorités : Urgence/Programmé/Ambulatoire
•	Checklist pré-opératoire sécurité patient
Dossier opératoire
Fiche intervention:
├── 📋 Programmation
│   ├── Patient et dossier médical
│   ├── Type d'intervention (CIM-10)
│   ├── Date et heure prévues
│   ├── Durée estimée
│   └── Salle attribuée
│
├── 👥 Équipe chirurgicale
│   ├── Chirurgien principal
│   ├── Assistant(s)
│   ├── Anesthésiste
│   ├── IADE
│   ├── IBODE
│   └── Autres intervenants
│
├── 🔧 Matériel & Consommables
│   ├── Instruments chirurgicaux
│   ├── Prothèses/Implants
│   ├── Médicaments spécifiques
│   ├── Consommables stériles
│   └── Équipements spécialisés
│
├── 📝 Compte-rendu opératoire
│   ├── Déroulement intervention
│   ├── Technique utilisée
│   ├── Constatations peropératoires
│   ├── Incidents/complications
│   ├── Prélèvements effectués
│   └── Prescriptions post-opératoires
│
└── 🏥 Suivi post-opératoire
    ├── Surveillance SSPI/Réanimation
    ├── Consignes de sortie
    ├── Rendez-vous contrôle
    └── Rééducation prescrite
 
🔹 9. URGENCES
Tableau de bord urgences
•	Tri patients : Couleurs selon gravité (CIMU/CCMU)
•	Salle d'attente : Patients en attente avec temps d'attente
•	Boxes : Statut occupation en temps réel
•	Indicateurs : Nombre patients/heure, temps attente moyen, durée prise en charge
Écran accueil urgences
•	Enregistrement rapide : Identité, motif, constantes vitales
•	Évaluation initiale par IOA (Infirmier d'Orientation et d'Accueil)
•	Attribution priorité selon grille CIMU
•	Orientation : Box, déchocage, salle d'attente, transfert
Prise en charge
Workflow urgences:
├── 🚨 Accueil & Tri
│   ├── Identification patient
│   ├── Constantes vitales
│   ├── Évaluation gravité
│   └── Attribution priorité
│
├── 🏥 Consultation médicale
│   ├── Anamnèse rapide
│   ├── Examen clinique
│   ├── Prescription examens
│   └── Traitement initial
│
├── 🔬 Examens complémentaires
│   ├── Biologie en urgence
│   ├── Imagerie
│   ├── ECG
│   └── Autres examens
│
└── 🎯 Orientation
    ├── Sortie avec ordonnance
    ├── Hospitalisation
    ├── Transfert autre service
    ├── Transfert autre établissement
    └── Décès (certificat)
 
🔹 10. FACTURATION & ASSURANCES
Génération automatique factures
•	Templates personnalisables (logo hôpital, mentions légales)
•	Numérotation automatique chronologique
•	Détail par actes : Consultations/Examens/Médicaments/Hospitalisation
•	Calculs automatiques : Remises, part assurance, reste à charge
•	Export PDF avec signature électronique
Gestion assurances
Écran assurances:
├── 📋 Conventions
│   ├── Liste assurances partenaires
│   ├── Taux de remboursement par acte
│   ├── Plafonds annuels
│   ├── Délais de carence
│   └── Procédures accord préalable
│
├── ✅ Vérification couverture
│   ├── Numéro adhérent/bénéficiaire
│   ├── Droits en cours validité
│   ├── Plafond restant
│   ├── Actes couverts
│   └── Franchise/Ticket modérateur
│
├── 📤 Transmission factures
│   ├── Télétransmission automatique
│   ├── Suivi remboursements
│   ├── Rejets et litiges
│   └── Relances impayés
│
└── 💰 Encaissements
    ├── Paiements assurance
    ├── Paiements patients
    ├── Modes de paiement
    └── Rapprochement bancaire
Écran facturation patient
•	Récapitulatif séjour : Durée, actes, médicaments, examens
•	Ventilation part assurance/patient
•	Devis préalable pour interventions programmées
•	Facilités de paiement : Échéancier, acomptes
•	Impression facture/reçu instantanée
 
🔹 11. COMPTABILITÉ HOSPITALIÈRE
Plan comptable hospitalier
•	TreeView hiérarchique (Classes SYSCOHADA adaptées santé)
•	Comptes spécifiques : Produits hospitaliers, charges médicales
•	Centres de coûts : Par service/département
Journal des opérations
•	Saisie comptable automatique depuis facturation
•	Écritures manuelles pour charges et investissements
•	Validation/Lettrage avec pièces justificatives
•	Export vers logiciel comptable externe
États financiers
Rapports disponibles:
├── 📊 Balance générale
├── 📋 Grand livre
├── 💼 Bilan comptable
├── 📈 Compte de résultat
│   ├── Produits d'exploitation (consultations, hospitalisations)
│   ├── Charges d'exploitation (personnel, achats, maintenance)
│   └── Résultat net
├── 🏦 Tableau de flux trésorerie
├── 📉 Analyse par service
│   ├── Rentabilité par département
│   ├── Coûts directs/indirects
│   └── Taux d'occupation/rentabilité
└── 📄 Déclarations fiscales
 
🔹 12. REPORTING & STATISTIQUES
Tableau de bord direction
Widgets analytics:
├── 📊 Indicateurs d'activité
│   ├── Nombre consultations/jour/mois
│   ├── Admissions/Sorties
│   ├── Taux d'occupation lits
│   ├── Durée moyenne séjour
│   └── Taux de rotation lits
│
├── 💰 Indicateurs financiers
│   ├── Chiffre d'affaires par service
│   ├── Recettes/Dépenses
│   ├── Taux de recouvrement
│   ├── Créances en cours
│   └── Délai paiement moyen
│
├── 👥 Indicateurs RH
│   ├── Taux d'absentéisme
│   ├── Ratio personnel/patients
│   ├── Heures supplémentaires
│   └── Turn-over
│
├── 🎯 Indicateurs qualité
│   ├── Taux de satisfaction patients
│   ├── Délai prise en charge urgences
│   ├── Taux infections nosocomiales
│   ├── Taux de réadmission
│   └── Événements indésirables
│
└── 📈 Tendances & Prévisions
    ├── Évolution activité 12 mois
    ├── Saisonnalité pathologies
    ├── Projections occupation
    └── Besoins en personnel
Rapports réglementaires
•	Registre des patients (archives légales)
•	Déclarations sanitaires obligatoires
•	Statistiques maladies à déclaration obligatoire
•	Rapports mortalité/morbidité
•	Suivi indicateurs qualité (certification)
Rapports personnalisables
•	Générateur de requêtes visuelles (drag & drop)
•	Templates prédéfinis : Activité mensuelle, Bilan service, État stocks
•	Planification automatique d'envoi par email
•	Formats d'export : PDF, Excel, CSV, Word
 
🔹 13. PARAMÈTRES & ADMINISTRATION
Configuration établissement
•	Informations hôpital (nom, adresse, RCCM, NIF, logo, cachet)
•	Structure organisationnelle (services, départements, pôles)
•	Nomenclature des actes (CCAM/NGAP adaptés)
•	Tarifs et barèmes (assurances, hors conventions)
•	Templates documents (ordonnances, certificats, attestations, comptes-rendus)
Gestion utilisateurs & sécurité
Profils d'accès:
├── 👑 Administrateur
│   └── Accès total, gestion système
│
├── 👨‍⚕️ Médecin
│   ├── Dossiers patients
│   ├── Prescriptions
│   ├── Consultations
│   └── Examens (lecture/prescription)
│
├── 👩‍⚕️ Infirmier
│   ├── Soins patients
│   ├── Constantes vitales
│   ├── Administration traitements
│   └── Préparation examens
│
├── 🔬 Laborantin/Radiologue
│   ├── Demandes examens
│   ├── Saisie résultats
│   └── Validation examens
│
├── 💊 Pharmacien
│   ├── Gestion stocks
│   ├── Dispensation
│   └── Approvisionnements
│
├── 💼 Comptable/Caissier
│   ├── Facturation
│   ├── Encaissements
│   ├── Rapports financiers
│   └── Gestion assurances
│
└── 📝 Secrétariat
    ├── Admissions
    ├── Rendez-vous
    ├── Documents administratifs
    └── Accueil/Renseignements
Traçabilité & Audit
•	Logs système : Toutes actions utilisateurs horodatées
•	Historique modifications dossiers patients (qui/quand/quoi)
•	Sauvegarde automatique avec versioning
•	Conformité RGPD : Consentements, droit à l'oubli, portabilité
Sauvegarde & Sécurité
•	Backup automatique SQLite chiffré (quotidien/hebdomadaire)
•	Import/Export base de données
•	Restauration à date donnée
•	Chiffrement données sensibles (AES-256)
•	Authentification forte (2FA disponible)
 
🎨 Interface Utilisateur
Design System
•	Material 3 Design avec palette médicale (bleu/vert/blanc)
•	Mode sombre/clair adapté environnement hospitalier
•	Responsive : Desktop/Tablette (consultations au lit du patient)
•	Accessibilité : Contrastes élevés, taille texte ajustable, navigation clavier
•	Codes couleurs : Rouge (urgence), Orange (prioritaire), Vert (stable)
Composants réutilisables
•	DataTables médicales avec tri/filtrage/export
•	Forms de saisie avec validation médicale (doses, interactions)
•	Charts : Courbes température, graphiques évolution biologiques
•	Calendriers : Planning médical, gardes, interventions
•	PDF Viewer/Generator : Comptes-rendus, ordonnances, certificats
•	Impression badges patients avec codes-barres
•	Lecteur code-barres/QR : Identification rapide patients/médicaments
 
⚡ Fonctionnalités Avancées
Performance & Optimisation
•	Pagination intelligente avec lazy loading
•	Cache résultats recherches fréquentes
•	Indexation optimisée (N° dossier, noms, dates)
•	Compression images médicales sans perte qualité
•	Mode offline complet avec synchronisation différée
Automatisations
•	Génération automatique comptes-rendus types
•	Calculs automatiques : IMC, clairance créatinine, scores cliniques
•	Alertes médicales : Interactions médicamenteuses, allergies, contre-indications
•	Rappels automatiques : RDV patients, renouvellements ordonnances, vaccins
•	Transmission automatique résultats au médecin prescripteur
Interopérabilité
•	Import : Annuaires assurances, listes médicaments, nomenclatures
•	Export : PMSI, DIM, statistiques sanitaires
•	HL7/FHIR : Standards échange données santé (préparation future)
•	API REST : Intégration télémédecine, laboratoires externes
Sécurité & Conformité
•	Conformité : Secret médical, RGPD santé
•	Droits d'accès granulaires par patient/dossier
•	Signature électronique documents médicaux
•	Chiffrement bout en bout données sensibles
•	Audit trail complet (certification HAS)
 
🔄 Workflows Types
1. Admission urgence → Hospitalisation
Urgences → Tri IOA → Consultation médecin → Examens → Décision hospitalisation
→ Recherche lit disponible → Affectation chambre → Transfert service
→ Ouverture dossier hospitalisation → Prescription traitements
2. Consultation externe programmée
Prise RDV (téléphone/web) → Confirmation automatique → Rappel J-1
→ Accueil patient → Vérification assurance → Consultation médecin
→ Prescription examens/traitements → Facturation → Paiement/Tiers-payant
→ Programmation suivi si nécessaire
3. Intervention chirurgicale
Consultation pré-opératoire → Examens pré-op → Accord assurance (accord préalable)
→ Programmation intervention → Checklist sécurité → Intervention
→ SSPI → Surveillance post-op → Hospitalisation → Convalescence → Sortie
→ RDV contrôle → Suivi post-opératoire
4. Dispensation médicaments
Prescription médicale → Validation pharmacien (interactions, contre-indications)
→ Vérification stock → Préparation (étiquetage posologie)
→ Dispensation au patient/service → Mise à jour stock → Facturation
5. Circuit examens
Prescription ex
5. Circuit examens
Prescription examen → Enregistrement demande → Programmation/Prélèvement
→ Réalisation examen → Saisie résultats → Validation biologiste/radiologue
→ Transmission médecin prescripteur → Interprétation → Archivage dossier
6. Sortie patient hospitalisé
Décision sortie médicale → Prescription sortie (ordonnances, soins)
→ Certificats/Attestations → Facturation finale → Vérification paiements
→ Libération chambre → Programmation RDV suivi → Sortie effective
→ Transmission documents (médecin traitant, pharmacie)
7. Gestion stock médicaments
Consommation → Alerte seuil minimum → Génération bon commande
→ Envoi fournisseur → Réception marchandise → Contrôle qualité
→ Enregistrement entrée stock → Rangement → Mise à jour inventaire
8. Facturation avec tiers-payant
Prestation médicale → Vérification droits assurance → Calcul part assurance/patient
→ Transmission électronique assurance → Encaissement part patient
→ Attente remboursement assurance → Rapprochement paiement → Clôture facture
 
🖥️ Maquettes de l'application de gestion hospitalière
1️⃣ Écran d'accueil / Dashboard
-------------------------------------------------------------------
| Menu Latéral     | Tableau de Bord Hospitalier                  |
| (Sidebar)        |----------------------------------------------|
|                  | [Carte] Patients hospitalisés : 142          |
| 📊 Dashboard     | [Carte] Consultations du jour : 87           |
| 👥 Patients      | [Carte] Urgences en attente : 12             |
| 🏥 Personnel     | [Carte] Lits disponibles : 23/180            |
| 🛏️ Chambres      |----------------------------------------------|
| 📅 Consultations | Graphique: Admissions sur 30 jours           |
| 🔬 Examens       |----------------------------------------------|
| 💊 Pharmacie     | ⚠️ ALERTES:                                  |
| 🏥 Urgences      | • 3 patients en état critique                |
| ⚕️ Interventions | • Stock antibiotiques faible                 |
| 💰 Facturation   | • Équipement radio en maintenance            |
| 📊 Rapports      |----------------------------------------------|
| ⚙️ Paramètres    | 📅 INTERVENTIONS DU JOUR:                    |
|                  | • 09h00 - Appendicectomie (Salle 2)         |
|                  | • 14h30 - Césarienne (Salle 1)              |
-------------------------------------------------------------------
2️⃣ Écran Gestion des Patients
-------------------------------------------------------------------
| Sidebar          | Registre des Patients                        |
|------------------|----------------------------------------------|
|                  | [🔍 Rechercher patient...] [+ Nouvelle admission] |
|                  |----------------------------------------------|
|                  | [Filtres: □ Hospitalisés □ Externes □ Urgences] |
|                  |----------------------------------------------|
|                  | Tableau interactif :                         |
|                  |----------------------------------------------|
|                  | N°    | Nom         | Âge | Chambre | Médecin | Statut   |
|                  |-------|-------------|-----|---------|---------|----------|
|                  | 00142 | Kofi Amen   | 45  | 305-A   | Dr Ada  | 🟢 Stable|
|                  | 00143 | Ama Koffi   | 32  | 201-B   | Dr Kokou| 🟡 Suivi |
|                  | 00144 | Edem Togo   | 67  | USI-03  | Dr Ada  | 🔴 Critique|
|                  | 00145 | Sena Ablavi | 28  | Externe | Dr Afi  | 🟢 Stable|
|                  |----------------------------------------------|
|                  | Pagination: ◀ 1 2 3 4 5 ▶  (20 patients/page)|
-------------------------------------------------------------------
3️⃣ Écran Dossier Patient Détaillé
-------------------------------------------------------------------
| ◀ Retour Patients | Dossier Patient: Kofi Amen (#00142)        |
|-------------------|----------------------------------------------|
| [Photo]           | 📋 Infos | 🏥 Médical | 💊 Traitements | 🔬 Examens | 💰 Facturation |
| Kofi Amen         |----------------------------------------------|
| 45 ans, M         | INFORMATIONS GÉNÉRALES:                      |
| Groupe: O+        | Nom complet: Kofi Amen                       |
|                   | Date naissance: 12/03/1979                   |
| Chambre: 305-A    | Téléphone: +228 90 12 34 56                  |
| Admission:        | Contact urgence: Ama Amen (Épouse)          |
| 25/12/2024        | Adresse: Lomé, Tokoin                        |
|                   |----------------------------------------------|
| Médecin:          | HOSPITALISATION ACTUELLE:                    |
| Dr. Ada Mensah    | Admission: 25/12/2024 via Urgences           |
|                   | Diagnostic: Pneumonie aiguë                  |
| ⚠️ Allergies:     | Service: Médecine interne                    |
| • Pénicilline     | Durée séjour: 6 jours                        |
| • Aspirine        |                                              |
|                   | CONSTANTES VITALES (dernière mesure):        |
| [Imprimer]        | Température: 37.2°C | Tension: 130/80        |
| [Transférer]      | Pouls: 78 bpm       | SpO2: 98%              |
| [Sortie]          |----------------------------------------------|
-------------------------------------------------------------------
4️⃣ Écran Consultations & Agenda
-------------------------------------------------------------------
| Sidebar          | Agenda Médical - Mercredi 31 Décembre 2024  |
|------------------|----------------------------------------------|
|                  | [Dr. Ada Mensah ▼] [Semaine ▼] [+ Nouveau RDV] |
|                  |----------------------------------------------|
|                  | 08:00 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ |
|                  | 09:00 ▓▓ Kofi Edem - Contrôle post-op        |
|                  | 10:00 ▓▓ Ama Sena - Consultation générale    |
|                  | 11:00 ░░░ Disponible ░░░░░░░░░░░░░░░░░░░░░░ |
|                  | 12:00 ━━━━━━━━━━━━ PAUSE ━━━━━━━━━━━━━━━━━ |
|                  | 13:00 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ |
|                  | 14:00 ▓▓ Edem Koku - Suivi diabète           |
|                  | 15:00 ▓▓ Sena Afi - Première visite          |
|                  | 16:00 ▓▓ Yawa Mensah - Résultats analyses    |
|                  | 17:00 ░░░ Disponible ░░░░░░░░░░░░░░░░░░░░░░ |
|                  |----------------------------------------------|
|                  | 🟢 Confirmé  🟡 En attente  🔴 Urgent  ⚪ Annulé |
-------------------------------------------------------------------
5️⃣ Écran Chambres & Occupation
-------------------------------------------------------------------
| Sidebar          | Gestion des Chambres - Étage 3              |
|------------------|----------------------------------------------|
|                  | [Tous les étages ▼] [Tous types ▼]          |
|                  |----------------------------------------------|
|                  | PLAN ÉTAGE 3:                                |
|                  |                                              |
|                  | ┌─────┬─────┬─────┐  ┌─────┬─────┬─────┐   |
|                  | │ 301 │ 302 │ 303 │  │ 310 │ 311 │ 312 │   |
|                  | │ 🟢  │ 🔴  │ 🟢  │  │ 🟡  │ 🟢  │ 🔴  │   |
|                  | └─────┴─────┴─────┘  └─────┴─────┴─────┘   |
|                  |                                              |
|                  | ┌─────┬─────┬─────┐  ┌─────┬─────┬─────┐   |
|                  | │ 304 │ 305 │ 306 │  │ 313 │ 314 │ 315 │   |
|                  | │ 🔴  │ 🔴  │ 🟢  │  │ 🟢  │ 🔴  │ 🟡  │   |
|                  | └─────┴─────┴─────┘  └─────┴─────┴─────┘   |
|                  |                                              |
|                  | 🟢 Libre  🔴 Occupé  🟡 En nettoyage         |
|                  |----------------------------------------------|
|                  | Taux d'occupation: ▓▓▓▓▓▓▓░░░ 75%            |
|                  | Chambres disponibles: 8/32                   |
-------------------------------------------------------------------
6️⃣ Écran Pharmacie & Stock
-------------------------------------------------------------------
| Sidebar          | Gestion Pharmacie & Stock                    |
|------------------|----------------------------------------------|
|                  | [🔍 Rechercher médicament...] [+ Nouvelle entrée] |
|                  |----------------------------------------------|
|                  | [Filtres: □ Stock faible □ Péremption proche] |
|                  |----------------------------------------------|
|                  | DCI              | Stock | Min | Péremption | Actions |
|                  |------------------|-------|-----|------------|---------|
|                  | Paracétamol 500mg| 2500  | 500 | 03/2026    | [👁️][✏️]|
|                  | Amoxicilline 1g  | 120   | 200 | ⚠️ 02/2025 | [👁️][✏️]|
|                  | Ibuprofène 400mg | 1800  | 300 | 06/2026    | [👁️][✏️]|
|                  | Morphine 10mg    | 45    | 50  | ⚠️ 01/2025 | [👁️][✏️]|
|                  |----------------------------------------------|
|                  | ⚠️ ALERTES STOCK:                            |
|                  | • 12 médicaments sous seuil minimum          |
|                  | • 5 lots arrivent à péremption (< 3 mois)    |
|                  | • Commande #CMD-2024-089 en attente          |
-------------------------------------------------------------------
7️⃣ Écran Examens & Laboratoire
-------------------------------------------------------------------
| Sidebar          | Gestion des Examens                          |
|------------------|----------------------------------------------|
|                  | [📋 En attente] [🔄 En cours] [✅ Terminés]  |
|                  |----------------------------------------------|
|                  | Date   | Patient     | Type      | Priorité | Statut   |
|                  |--------|-------------|-----------|----------|----------|
|                  | 31/12  | Kofi Amen   | NFS       | 🔴 Urgent| En cours |
|                  | 31/12  | Ama Koffi   | Radio     | 🟡 Normal| En attente|
|                  | 31/12  | Edem Togo   | Scanner   | 🔴 Urgent| Terminé  |
|                  | 31/12  | Sena Ablavi | Glycémie  | 🟢 Routine| En cours |
|                  |----------------------------------------------|
|                  | DÉTAIL EXAMEN: NFS - Kofi Amen (#00142)      |
|                  |----------------------------------------------|
|                  | Globules rouges: 4.5 M/mm³ [4.5-5.5] ✓       |
|                  | Hémoglobine: 13.2 g/dL [13-17] ✓             |
|                  | Leucocytes: 12.8 k/mm³ [4-10] ⚠️ ÉLEVÉ       |
|                  | Plaquettes: 250 k/mm³ [150-400] ✓            |
|                  |----------------------------------------------|
|                  | [Valider résultats] [Imprimer] [Transmettre] |
-------------------------------------------------------------------
8️⃣ Écran Urgences
-------------------------------------------------------------------
| Sidebar          | Service des Urgences                         |
|------------------|----------------------------------------------|
|                  | 🚨 PATIENTS EN ATTENTE: 12                   |
|                  | ⏱️ Temps d'attente moyen: 45 min             |
|                  |----------------------------------------------|
|                  | TRI | Patient      | Âge | Arrivée | Motif      | Attente |
|                  |-----|--------------|-----|---------|------------|---------|
|                  | 🔴 1| Kofi Edem    | 35  | 14:20   | Trauma     | 10 min  |
|                  | 🟠 2| Ama Sena     | 67  | 14:05   | Doul.thorax| 25 min  |
|                  | 🟡 3| Edem Koku    | 28  | 13:50   | Fièvre     | 40 min  |
|                  | 🟢 4| Sena Afi     | 22  | 13:30   | Entorse    | 60 min  |
|                  |----------------------------------------------|
|                  | BOXES:                                       |
|                  | Box 1: 🔴 Occupé - Ama Mensah (Trauma grave)|
|                  | Box 2: 🟢 Libre                              |
|                  | Box 3: 🔴 Occupé - Yawa Koffi (Suivi)       |
|                  | Déchocage: 🟢 Disponible                     |
|                  |----------------------------------------------|
|                  | [+ Nouvel arrivant] [Appeler suivant]        |
-------------------------------------------------------------------
9️⃣ Écran Facturation
-------------------------------------------------------------------
| Sidebar          | Facturation Patient                          |
|------------------|----------------------------------------------|
|                  | PATIENT: Kofi Amen (#00142)                  |
|                  | Assurance: INAM (70% remboursement)          |
|                  |----------------------------------------------|
|                  | DÉTAIL SÉJOUR (25/12 - 31/12):               |
|                  |                                              |
|                  | Hospitalisation (6 jours × 15 000)  90 000   |
|                  | Consultations spécialisées (2)      40 000   |
|                  | Examens laboratoire                 25 000   |
|                  | Imagerie médicale (Radio)           15 000   |
|                  | Médicaments                         45 000   |
|                  | Soins infirmiers                    20 000   |
|                  |                        ─────────────────────  |
|                  | TOTAL:                             235 000   |
|                  |                                              |
|                  | Part INAM (70%):                  -164 500   |
|                  | ═════════════════════════════════════════    |
|                  | RESTE À CHARGE PATIENT:            70 500    |
|                  |----------------------------------------------|
|                  | [Générer facture] [Encaisser] [Imprimer]     |
-------------------------------------------------------------------
🔟 Écran Rapports & Statistiques
-------------------------------------------------------------------
| Sidebar          | Tableau de Bord Direction                    |
|------------------|----------------------------------------------|
|                  | [Période: Décembre 2024 ▼]                   |
|                  |----------------------------------------------|
|                  | 📊 ACTIVITÉ:                                 |
|                  | Consultations: 2 450 | Admissions: 342        |
|                  | Interventions: 89    | Taux occupation: 78%   |
|                  |----------------------------------------------|
|                  | 💰 FINANCES:                                 |
|                  | CA total: 125 M FCFA | Recouvrements: 98 M    |
|                  | Créances: 27 M       | Taux recouvrement: 78% |
|                  |----------------------------------------------|
|                  | [Graphique] Évolution CA mensuel             |
|                  |    ▂▃▅▆▇█▇▆▅▇█▉  (Jan-Déc 2024)            |
|                  |----------------------------------------------|
|                  | [Graphique] Répartition par service          |
|                  | Chirurgie: ████████░░ 40%                    |
|                  | Médecine:  ██████░░░░ 30%                    |
|                  | Urgences:  ████░░░░░░ 20%                    |
|                  | Autres:    ██░░░░░░░░ 10%                    |
|                  |----------------------------------------------|
|                  | [Télécharger rapport PDF] [Export Excel]     |
-------------------------------------------------------------------
 
🎨 Améliorations visuelles possibles
•	Thème médical avec couleurs apaisantes (bleu/vert/blanc)
•	Dark Mode adapté pour gardes de nuit
•	Badges colorés dynamiques pour statuts patients:
o	🟢 Stable / 🟡 Surveillance / 🔴 Critique / ⚪ Sorti
•	Graphiques temps réel avec animations fluides
•	Notifications push pour alertes urgentes
•	Code couleur urgences : CIMU 1-5 (rouge → bleu)
•	Icons médicaux intuitifs pour navigation rapide
•	Design responsive tablette pour consultations mobiles
•	Impression thermique optimisée pour tickets/reçus
•	QR codes patients pour identification rapide
•	Tableaux de bord personnalisables par profil utilisateur
 
📊 Indicateurs de Performance (KPI)
Qualité des soins
•	Taux de satisfaction patients ≥ 85%
•	Délai prise en charge urgences ≤ 30 min
•	Taux infections nosocomiales ≤ 2%
•	Taux de réadmission à 30 jours ≤ 5%
Efficacité opérationnelle
•	Taux d'occupation lits: 75-85%
•	Durée moyenne séjour (DMS) optimale
•	Taux rotation lits
•	Temps d'attente consultations ≤ 20 min
Performance financière
•	Taux de recouvrement ≥ 90%
•	Délai paiement moyen ≤ 30 jours
•	Marge opérationnelle par service
•	Coût journée d'hospitalisation
Ressources humaines
•	Ratio infirmier/patients: 1/8
•	Taux d'absentéisme ≤ 5%
•	Taux de turn-over ≤ 10%
•	Heures supplémentaires/mois
 
🚀 Évolutions futures possibles
Court terme (3-6 mois)
•	Application mobile pour patients (RDV, résultats)
•	Téléconsultation intégrée
•	Signature électronique ordonnances
•	Lecteur biométrique (empreintes)
Moyen terme (6-12 mois)
•	IA pour aide au diagnostic
•	Prédiction d'occupation lits
•	Analyse automatique imagerie médicale
•	Chatbot accueil patients
Long terme (12+ mois)
•	Dossier médical partagé inter-établissements
•	Blockchain pour traçabilité médicaments
•	IoT médical (monitoring patients à distance)
•	Intégration complète HL7/FHIR


