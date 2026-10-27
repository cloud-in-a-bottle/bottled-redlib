import time

import requests
from openhost_test_harness import OpenhostStack


def _anonymous_get(stack: OpenhostStack, path: str) -> requests.Response:
    """GET without the owner cookie, retrying while the app finishes booting."""
    deadline = time.monotonic() + 60
    while True:
        try:
            response = requests.get(f"{stack.url}{path}", headers={"Accept": "text/html"}, timeout=30)
            if response.status_code < 500 or time.monotonic() > deadline:
                return response
        except requests.ConnectionError:
            if time.monotonic() > deadline:
                raise
        time.sleep(2)


def test_anonymous_visitors_can_use_the_app(stack: OpenhostStack) -> None:
    """public_paths = ["/"]: anyone with the URL reaches Redlib directly, not the router's login page."""
    for path in ("/settings", "/info.json"):
        response = _anonymous_get(stack, path)
        assert response.status_code == 200 and response.url.startswith(stack.url), (
            f"anonymous GET {path} ended at {response.url} with {response.status_code}: {response.text[:300]}"
        )


def test_rss_is_enabled(stack: OpenhostStack) -> None:
    """The Dockerfile sets REDLIB_ENABLE_RSS=on; without it every .rss feed is an error page."""
    config = _anonymous_get(stack, "/info.json").json()["config"]
    assert config.get("REDLIB_ENABLE_RSS") == "on", f"instance config: {config}"
    # The feed itself needs Reddit, which may be unreachable from CI, so only check RSS isn't switched off.
    feed = _anonymous_get(stack, "/r/rust.rss")
    assert "RSS is disabled on this instance" not in feed.text, f"/r/rust.rss: {feed.status_code}: {feed.text[:300]}"
