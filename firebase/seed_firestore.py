"""Create restaurant documents in Cloud Firestore from restaurants.json.

Requires: pip install google-cloud-firestore
Authentication: use Application Default Credentials or GOOGLE_APPLICATION_CREDENTIALS.
Existing restaurant documents are skipped so running this again preserves edits.
"""

import argparse
import json
from pathlib import Path


SEED_FILE = Path(__file__).with_name("restaurants.json")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", required=True, help="Firebase project ID")
    parser.add_argument(
        "--apply", action="store_true", help="Create missing Firestore documents"
    )
    args = parser.parse_args()

    restaurants = json.loads(SEED_FILE.read_text(encoding="utf-8"))["restaurants"]
    print(f"{len(restaurants)} restaurant documents for project {args.project}")
    if not args.apply:
        print("Preview only. Add --apply to create missing documents.")
        return

    from google.cloud import firestore

    client = firestore.Client(project=args.project)
    collection = client.collection("restaurants")
    created = 0
    skipped = 0
    for restaurant_id, fields in restaurants.items():
        document = collection.document(restaurant_id)
        if document.get().exists:
            skipped += 1
            continue
        document.create(fields)
        created += 1

    print(f"Created {created}; skipped {skipped} existing documents.")


if __name__ == "__main__":
    main()
