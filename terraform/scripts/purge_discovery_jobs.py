import os
import json
import requests
import time


class InfobloxSession:
    def __init__(self):
        self.base_url = "https://csp.infoblox.com"
        self.email = os.getenv("INFOBLOX_EMAIL")
        self.password = os.getenv("INFOBLOX_PASSWORD")
        self.jwt = None
        self.session = requests.Session()
        self.headers = {"Content-Type": "application/json"}

    def login(self):
        payload = {"email": self.email, "password": self.password}
        response = self.session.post(
            f"{self.base_url}/v2/session/users/sign_in",
            headers=self.headers,
            json=payload,
        )
        response.raise_for_status()
        self.jwt = response.json().get("jwt")
        print("Logged in and JWT acquired")

    def switch_account(self):
        sandbox_id = self._read_file("sandbox_id.txt")
        payload = {"id": f"identity/accounts/{sandbox_id}"}
        headers = self._auth_headers()
        response = self.session.post(
            f"{self.base_url}/v2/session/account_switch",
            headers=headers,
            json=payload,
        )
        response.raise_for_status()
        self.jwt = response.json().get("jwt")
        print(f"Switched to sandbox {sandbox_id} and updated JWT")

    def purge_all_providers(self):
        url = f"{self.base_url}/api/cloud_discovery/v2/providers"
        response = self.session.get(url, headers=self._auth_headers())
        response.raise_for_status()
        providers = response.json().get("results", [])

        if not providers:
            print("No discovery providers found. Nothing to purge.")
            return

        print(f"Found {len(providers)} discovery provider(s). Deleting all...")

        for provider in providers:
            provider_id = provider.get("id")
            provider_name = provider.get("name", "unknown")
            delete_url = f"{self.base_url}/api/cloud_discovery/v2/providers/{provider_id}"

            try:
                resp = requests.delete(delete_url, headers=self._auth_headers())
                if resp.status_code in [200, 204]:
                    print(f"Deleted provider: {provider_name} ({provider_id})")
                else:
                    print(f"WARNING: Failed to delete {provider_name}: {resp.status_code} {resp.text}")
            except Exception as e:
                print(f"ERROR: Exception deleting {provider_name}: {e}")

            time.sleep(2)

        print("Purge complete.")

    def _auth_headers(self):
        return {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.jwt}",
        }

    def _read_file(self, filename):
        with open(filename, "r") as f:
            return f.read().strip()


if __name__ == "__main__":
    session = InfobloxSession()
    session.login()
    session.switch_account()
    session.purge_all_providers()
