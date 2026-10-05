# LocalBite

A Flutter app to discover local restaurants, save favourites, and write reviews.
Uses Firebase Authentication and Cloud Firestore.

## Run

Install Flutter and enable Email/Password Authentication and Cloud Firestore in Firebase.

```sh
flutter pub get
flutter run
```

## Firebase setup

Deploy the rules and add restaurant data using an account with Firestore write access:

```sh
firebase deploy --project localbite-6d8e8 --only firestore:rules
gcloud auth application-default login
python3 -m pip install google-cloud-firestore
python3 firebase/seed_firestore.py --project localbite-6d8e8 --apply
```
