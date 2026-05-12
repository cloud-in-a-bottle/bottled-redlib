# openhost-redlib

[Redlib](https://github.com/redlib-org/redlib) — privacy-respecting
Reddit frontend (community-maintained Libreddit fork) — packaged as
an OpenHost app. Browse Reddit content without JS, without an account,
without Reddit's tracking.

## What you get

- Redlib running on `https://redlib.<zone>/`.
- Public: anyone with the URL can browse. No SSO.
- ~10 MiB RSS at idle; ~50 MiB under load.
- Zero persistent state (user preferences live as URL query strings
  client-side).

## Usage

After deploy, visit `https://redlib.<zone>/r/<subreddit>` for any
subreddit. The first page lists hot posts; click through to comment
threads. `/r/<sub>/comments/<id>` for individual posts. `/user/<u>`
for user profiles. RSS feeds at `/r/<sub>.rss`.

## Caveats

- **Reddit rate-limits server IPs.** Redlib uses Reddit's public
  JSON endpoints which Reddit aggressively throttles when traffic
  doesn't look like a real browser. On a heavily-used zone you may
  see "Reddit refused our request" errors during peak times. The
  workaround upstream recommends: point Redlib at a Tor SOCKS proxy
  via `REDLIB_HTTP_PROXY=socks5://...` so outbound calls rotate
  through Tor exit nodes. Not wired up by default in this package.
- **Reddit changes their public JSON occasionally.** Redlib usually
  patches within days, but a deploy of an old Redlib version can
  start showing 500s for some pages after Reddit changes their
  feed shape. Bump the `FROM` tag in the Dockerfile to update.
- **No multi-user accounts.** Redlib doesn't have a notion of
  signed-in Reddit users; it can only read public content. If
  you need to post / vote / DM, this is the wrong tool.

## Configuration

Redlib reads environment variables for default theme, NSFW filter,
etc. Full list at
[redlib-org/redlib#configuration](https://github.com/redlib-org/redlib#configuration).
None set by default; to override, edit `openhost.toml`:

```toml
[runtime.container]
# ...
env = [
    { name = "REDLIB_DEFAULT_THEME", value = "dark" },
    { name = "REDLIB_SFW_ONLY", value = "off" },
]
```

(Plus a redeploy.)
