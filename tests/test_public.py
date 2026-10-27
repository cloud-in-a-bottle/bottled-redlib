import time

import requests
from openhost_test_harness import OpenhostStack


def _get(stack: OpenhostStack, path: str, session: requests.Session | None = None) -> requests.Response:
    """GET (by default without the owner cookie), retrying while the app finishes booting."""
    session = session or requests.Session()
    deadline = time.monotonic() + 60
    while True:
        try:
            response = session.get(f"{stack.url}{path}", headers={"Accept": "text/html"}, timeout=30)
            if response.status_code < 500 or time.monotonic() > deadline:
                return response
        except requests.ConnectionError:
            if time.monotonic() > deadline:
                raise
        time.sleep(2)


def test_anonymous_visitors_can_use_the_app(stack: OpenhostStack) -> None:
    """public_paths = ["/"]: anyone with the URL reaches Redlib directly, not the router's login page."""
    for path in ("/settings", "/info.json"):
        response = _get(stack, path)
        assert response.status_code == 200 and response.url.startswith(stack.url), (
            f"anonymous GET {path} ended at {response.url} with {response.status_code}: {response.text[:300]}"
        )


def test_rss_is_enabled(stack: OpenhostStack) -> None:
    """The Dockerfile sets REDLIB_ENABLE_RSS=on; without it every .rss feed is an error page."""
    config = _get(stack, "/info.json", stack.owner_session).json()["config"]
    assert config.get("REDLIB_ENABLE_RSS") == "on", f"instance config: {config}"
    # The feed itself needs Reddit, which may be unreachable from CI, so only check RSS isn't switched off.
    feed = _get(stack, "/r/rust.rss", stack.owner_session)
    assert "RSS is disabled on this instance" not in feed.text, f"/r/rust.rss: {feed.status_code}: {feed.text[:300]}"
