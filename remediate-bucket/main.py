#!/usr/bin/env python3
"""Cloud Function (Gen2, Pub/Sub trigger): strip public access from a GCS bucket.

Deploy:
  gcloud functions deploy sentinel-remediate-bucket \
    --gen2 --runtime=python312 --region=us-central1 \
    --source=remediate-bucket --entry-point=remediate \
    --trigger-topic=sentinel-bucket-events \
    --service-account=sentinel-soar@PROJECT_ID.iam.gserviceaccount.com

Notes:
  - Gen2 delivers the Pub/Sub message as a CloudEvent, so the handler takes a
    single `cloud_event` arg and the base64 payload is at
    cloud_event.data["message"]["data"] (one level deeper than Gen1's event["data"]).
  - The Eventarc trigger invokes this service as its runtime SA, which therefore
    needs roles/run.invoker on the deployed Cloud Run service.
"""
import base64, json
import functions_framework
from google.cloud import storage


@functions_framework.cloud_event
def remediate(cloud_event):
    data = cloud_event.data["message"]["data"]
    payload = json.loads(base64.b64decode(data).decode("utf-8"))
    bucket_name = payload.get("resource", {}).get("labels", {}).get("bucket_name")
    if not bucket_name:
        print("No bucket name in event; skipping.")
        return

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    policy = bucket.get_iam_policy(requested_policy_version=3)

    changed = False
    for binding in policy.bindings:
        members = binding.get("members", set())
        for public in ("allUsers", "allAuthenticatedUsers"):
            if public in members:
                members.discard(public)
                changed = True
                print(f"Removed {public} from {bucket_name} ({binding['role']})")

    if changed:
        bucket.set_iam_policy(policy)
        print(f"REMEDIATED public access on {bucket_name}")
    else:
        print(f"No public access on {bucket_name}; no action.")
