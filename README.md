# bottled-redlib

[Redlib](https://github.com/redlib-org/redlib) is a privacy-respecting
Reddit frontend (community-maintained Libreddit fork), packaged as a Cloud in
a Bottle app. This package runs [Nachtalb's fork](https://github.com/Nachtalb/redlib),
which keeps working as Reddit changes; upstream Redlib currently fails on
every page. Browse Reddit content without JS, without an account, without
Reddit's tracking.

## What you get

- Redlib running on `https://redlib.<zone>/`.
- Public: anyone with the URL can browse. No SSO.
- RSS feeds.
- ~10 MiB memory at idle; ~50 MiB under load.
- Zero persistent state (user preferences live as URL query strings
  client-side).

## Usage

After deploy, visit `https://redlib.<zone>/r/<subreddit>` for any
subreddit. The first page lists hot posts; click through to comment
threads. `/r/<sub>/comments/<id>` for individual posts. `/user/<u>`
for user profiles.

## Caveats

- **Reddit rate-limits and blocks server IPs.** Reddit throttles
  traffic that doesn't look like a real browser, so on a heavily-used
  zone you may see "Reddit refused our request" errors at peak times.
  If Reddit blocks your server outright, the fork can send a logged-in
  Reddit session (`REDLIB_REDDIT_COOKIE`, see its
  [CONFIGURATION.md](https://github.com/Nachtalb/redlib/blob/main/CONFIGURATION.md#reddit-session)),
  or route requests through a proxy such as Tor
  (`REDLIB_HTTP_PROXY=socks5://...`). Neither is wired up by default
  in this package.
- **Reddit changes their public JSON occasionally.** Redlib usually
  patches within days, but a deploy of an old Redlib version can
  start showing errors on every page after Reddit changes things.
  To update, bump the pinned image tag and digest in the `Dockerfile`
  (see the comment there) and the commit in `NOTICE`.
- **No multi-user accounts.** Redlib doesn't have a notion of
  signed-in Reddit users; it can only read public content. If
  you need to post / vote / DM, this is the wrong tool.

## License

Redlib is licensed under the GNU Affero General Public License v3.0
(AGPL-3.0-only). Because the image built from this repository includes Redlib,
the image as a whole is distributed under the AGPL-3.0; see `LICENSE`. The
corresponding source is `Nachtalb/redlib` at the commit of the image pinned
in the `Dockerfile`; details and attribution are in `NOTICE`.

The packaging files original to this repository (the `Dockerfile`,
`cloudinabottle.toml`, and docs) are additionally offered under the MIT License (see
`NOTICE`).
