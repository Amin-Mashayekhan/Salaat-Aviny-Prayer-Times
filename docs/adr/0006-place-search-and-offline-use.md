# ADR 0006 — Place search on public servers, with offline use afterwards

Status: accepted (2026-11-12).

## Context

The bundled database holds 566 verified Iranian cities (`packages/owghat_lib/assets/data`). People outside
Iran, and people in villages that are not in the list, still need prayer times, and the qibla map needs a
way to jump to a named place. Prayer times for a place need four things: coordinates, an IANA time-zone
id (for the UTC offset), the height above sea level, and a name to show. Shipping a world city database
with zones and Persian, Arabic and other spellings would be large and would go stale, and the project's
rule is that the network is used only when the user asks for it (see [CLAUDE.md](../../CLAUDE.md)).

## Decision

1. **Two services, two jobs.** The name search uses OpenStreetMap's **Nominatim**
   (`/search?format=jsonv2`, `accept-language` set to the app language, `addressdetails=1`, `dedupe=1`,
   and `featureType=settlement` when only cities, towns and villages are wanted). The time zone and
   height of the chosen point come from **Open-Meteo** (`/v1/forecast` with `timezone=auto`; the answer's
   `timezone` and `elevation` fields are read, the height clamped to 0..9000 m, the coordinates sent with
   four decimals).
2. **One request per press of Search, nothing while typing, nothing in the background.** Searching needs
   at least two characters, runs one request at a time and drops a late answer to an old request. The
   same query in the same run is answered from memory instead of asking again. Choosing a result sends
   one more request (Open-Meteo) when the flow needs a time zone.
3. **Consent in plain words before anything is sent.** The search panel (`PlaceSearchPanel`) shows a
   notice that the typed text goes to the OpenStreetMap search service, that nothing else is sent and that
   the app works offline afterwards, plus an attribution line for both services. Failures are explained
   with a next step: offline, timeout, server busy (HTTP 429, 503, 509), time zone not fetched, generic.
4. **The result is stored as a custom `SavedLocation`** (name as returned, coordinates, IANA zone, height)
   through `savedLocationFromPlace` and `SettingsController.addLocation`. From then on the prayer times
   are computed offline from the bundled time-zone database, like any other saved location. A place is
   refused, with an explanation, when its zone is not in the bundled database or its latitude is beyond
   89.9 degrees. Choosing the same place twice (same name within about 2 km) reuses the saved one. In
   Settings a found place is added without becoming active; in onboarding it becomes the active location.
5. **The qibla map's "any point" search needs only the name search.** It moves the measuring point for the
   current session (nothing stored, no Open-Meteo request, no time zone needed).
6. **Map pictures are never bulk-downloaded.** The map is off until the user presses "Show the map"
   (`qibla.mapEnabled`, default off). Tiles come from OpenStreetMap (street) or Esri World Imagery
   (satellite) only for the area being looked at, with a bounded on-disk cache of 16 MB
   (`qiblaTileCacheBytes`), so moving the map back and forth does not ask again. In the satellite style,
   zoom levels beyond 18 enlarge the zoom-18 picture instead of requesting tiles that are often empty.
7. **Both requests identify the app and nothing about the person**: the `User-Agent` carries the project
   page, as the servers' usage policies ask, and there is no account, key, cookie or device identifier.

Where it lives:

- `core/platform/place_search.dart`: `PlaceSearchService` (`search`, `details`), `FoundPlace`,
  `PlaceDetails`, `PlaceSearchFailure`, `PlaceSearchException`, `UnsupportedPlaceSearch`;
  `core/platform/http_get.dart`: the injectable `HttpGetText` over `dart:io`.
- `features/places/data/online_place_search.dart`: `OnlinePlaceSearch` (the real implementation, created
  by the runner and handed over through `PlatformServices.placeSearch`) and the two response parsers.
- `features/places/application/`: `PlaceSearchModel` (state of one search box) and
  `savedLocationFromPlace` / `sameSavedPlace`.
- `features/places/presentation/place_search_panel.dart`: the shared panel, used by onboarding, Settings >
  Location and the qibla map. Tests use `FakePlaceSearch`.

## Consequences

- The typed text, the chosen point's coordinates (to Open-Meteo) and the usual connection data (the IP
  address) reach third-party servers, but only on an explicit press, and the notice above the search box
  says so. Nothing is stored about it beyond the saved location the user chose.
- The app depends on public servers with usage limits meant for light use. For a wide release a keyed or
  self-hosted provider is advisable; the swap is confined to `OnlinePlaceSearch` and the tile URL
  constants (`qiblaTileUrlTemplate`, `qiblaSatelliteTileUrlTemplate`).
- A saved place keeps the name in the language it was searched in; it is not translated later.
- Offline behaviour is unchanged: the Iranian list, the calculation, the schedule and the compass need no
  network at all.

## Alternatives considered

- **Open-Meteo geocoding alone** (one provider, and it also returns the zone and height): it cannot match
  many Persian and Arabic spellings of place names, which is the main audience of this app. That is why
  Nominatim does the name search.
- **Nominatim alone**: it gives no time zone or height, and deriving a zone from the longitude would be
  wrong for most places. Hence the second, separate lookup.
- **A bundled world city database** (for example GeoNames cities with zones): works offline, but adds
  size, goes stale, and still lacks many spellings and villages. It remains possible later as an
  addition, not a replacement.
- **Search while typing**: smoother, but it multiplies requests, would send half-typed text, and the
  public server's usage policy does not allow it.
- **Asking the user for the zone**: the Custom location form in Settings still exists for that, and is
  the suggested way out when a found place has an unknown zone.
