# 🧠 Quiz-Genius

[![Flutter](https://img.shields.io/badge/Flutter-v3.11+-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0+-0175C2?logo=dart&logoColor=white&style=for-the-badge)](https://dart.dev)
[![API](https://img.shields.io/badge/Powered%20By-OpenRouter%20%2F%20Gemini-FF6C37?style=for-the-badge&logo=google-gemini&logoColor=white)](https://openrouter.ai/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Quiz-Genius** est une application Flutter moderne et haut de gamme conçue pour transformer instantanément vos cours, fichiers PDF et captures d'écran en quiz interactifs grâce à l'Intelligence Artificielle. Idéal pour réviser efficacement, suivre sa progression et mémoriser sur le long terme.

---

## ✨ Fonctionnalités Majeures

*   🧠 **Génération par IA (OpenRouter & Gemini-2.0)** : Analyse de vos cours textuels pour créer des QCM pertinents et diversifiés avec explications détaillées pour chaque réponse.
*   📄 **Import PDF & Documents** : Importez directement des cours au format PDF pour générer des quiz sans copier-coller (propulsé par `syncfusion_flutter_pdf`).
*   📷 **Numérisation de documents (OCR)** : Extrayez du texte directement depuis des photos ou captures d'écran à l'aide de l'OCR (`google_mlkit_text_recognition`).
*   📊 **Tableau de Bord & Statistiques** : Visualisez votre progression globale et vos scores sous forme de graphiques élégants (grâce à `fl_chart`).
*   📜 **Historique Persistant** : Conservez une trace de vos anciennes sessions, révisez vos réponses et analysez vos erreurs.
*   🌗 **Design Premium & Mode Sombre** : Une interface utilisateur soignée avec des dégradés modernes, des micro-animations fluides (`animate_do`), et une gestion dynamique du thème.
*   🔒 **Sécurisation de la Clé API** : Gestion sécurisée de la clé d'API OpenRouter via un fichier d'environnement `.env`.

---

## 🛠️ Technologies & Bibliothèques Utilisées

L'application exploite les meilleures technologies de l'écosystème Flutter/Dart :

*   **Gestion d'État** : `provider` (architecture propre et réactive)
*   **Base de Données Locale** : `shared_preferences` (stockage de l'historique et des statistiques)
*   **Visualisation** : `fl_chart` (pour les graphiques d'évolution et de réussite)
*   **Animations** : `animate_do` (animations d'entrée fluides et transitions premium)
*   **Traitement de Fichiers** : `file_picker` et `syncfusion_flutter_pdf`
*   **Reconnaissance Visuelle** : `google_mlkit_text_recognition` et `image_picker`
*   **Sécurité** : `flutter_dotenv` (chargement sécurisé des variables d'environnement)

---

## 🚀 Commencer

### Prérequis

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.11.4 ou supérieure)
*   Un éditeur comme [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio)
*   Une clé API **OpenRouter** (obtenable gratuitement ou en crédits payants sur [openrouter.ai](https://openrouter.ai/))

### Installation

1.  **Cloner le dépôt** :
    ```bash
    git clone https://github.com/votre-compte/quizzgenius.git
    cd quizzgenius
    ```

2.  **Installer les dépendances** :
    ```bash
    flutter pub get
    ```

3.  **Configurer le fichier d'environnement** :
    *   Dupliquez le fichier `.env.example` et renommez-le en `.env` à la racine du projet :
        ```bash
        cp .env.example .env
        ```
    *   Ouvrez le fichier `.env` et remplacez la valeur factice par votre clé API OpenRouter :
        ```env
        OPENROUTER_API_KEY=votre_cle_api_ici
        ```

    > [!IMPORTANT]
    > Ne committez **jamais** votre fichier `.env` sur un dépôt public. Il a été ajouté par défaut dans le fichier `.gitignore`.

4.  **Lancer l'application** :
    *   Pour un appareil ou simulateur connecté :
        ```bash
        flutter run
        ```

---

## 📂 Structure du Projet

L'application est structurée de manière modulaire pour faciliter son évolution et sa maintenance :

```text
lib/
├── models/             # Modèles de données (Question, Historique, etc.)
├── providers/          # Gestionnaires d'état (QuizProvider, ThemeProvider)
├── screens/            # Écrans de l'interface utilisateur
│   ├── home_screen.dart       # Saisie de texte / Import de fichiers
│   ├── quiz_screen.dart       # Déroulement du quiz interactif
│   ├── results_screen.dart    # Résultat détaillé de la session
│   ├── history_screen.dart    # Liste des anciens quiz
│   ├── stats_screen.dart      # Graphiques & données analytiques
│   ├── settings_screen.dart   # Paramètres du profil & du thème
│   └── splash_screen.dart     # Écran d'accueil animé
├── services/           # Services locaux (Shared Preferences / Stockage)
├── utils/              # Thèmes et styles graphiques globaux
└── main.dart           # Point d'entrée de l'application (initialisation .env)
```

---

## 🔒 Sécurité

Pour préserver vos clés d'API et éviter toute fuite, nous chargeons l'API Key de manière dynamique.
En production ou pour les tests :
*   Le fichier `.env` est exclu du contrôle de version.
*   En cas d'absence du fichier `.env` lors du chargement, une exception est interceptée et affichée proprement dans les logs de débogage pour guider l'utilisateur.

---

## 📝 Licence

Distribué sous licence MIT. Voir `LICENSE` pour plus d'informations.
