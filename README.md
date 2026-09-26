# LocalBite

Flutter restaurant discovery app using Firebase Authentication and Cloud Firestore.
Restaurants, reviews, user profiles, and favourites are stored in Firestore.
Restaurant and review lists use live Firestore snapshot listeners. Users can create,
read, update, and delete their own reviews in the app.

## Firestore setup

1. In Firebase Console for project `localbite-6d8e8`, create a Cloud Firestore
   database in Native mode and enable Email/Password Authentication.
2. Deploy the security rules in [`firebase/firestore.rules`](firebase/firestore.rules):

   ```sh
   firebase deploy --project localbite-6d8e8 --only firestore:rules
   ```

3. Seed the restaurant collection using the existing restaurant data. The seed
   script requires Google Application Default Credentials with Firestore write
   access (for example, `gcloud auth application-default login`) and the Python
   Firestore client:

   ```sh
   python3 -m pip install google-cloud-firestore
   python3 firebase/seed_firestore.py --project localbite-6d8e8
   python3 firebase/seed_firestore.py --project localbite-6d8e8 --apply
   ```

   The first run previews the count. The second creates missing restaurant
   documents and skips IDs that already exist. Firestore data is organized as:

   ```text
   restaurants/{restaurantId}
   reviews/{reviewId}
   users/{uid}
   users/{uid}/favourites/{restaurantId}
   ```

4. Run `flutter pub get` and `flutter run`.

The Firestore rules let signed-in users read restaurants and reviews. Each user
can edit only their own reviews, profile, and favourites. Restaurant writes
from the app are disabled; the seed script uses administrative credentials.

The assignment PDF names Realtime Database, so document the lecturer's
Firestore approval in the submission or viva.
