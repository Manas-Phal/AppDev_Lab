# SpaceX Launch Tracker App

## Description
A Flutter app that fetches live SpaceX launch data from the public REST API and displays it in a scrollable list. Handles loading, error, empty states, retry, and pull-to-refresh.

## Features
- Fetch live SpaceX launch data (no mock JSON)
- Loading spinner while fetching
- Error handling with Retry button
- Pull-to-refresh to update list
- Empty state handling
- Cached last successful result using SharedPreferences
- Responsive UI with cards, icons, and consistent spacing

## REST API
- Endpoint: `https://api.spacexdata.com/v4/launches`
- HTTP Method: GET
- Returns JSON with launch details
- Rate limits: public API, limited to reasonable request frequency

## Learning Outcome
- Understanding REST API and JSON parsing
- Handling HTTP status codes and network errors
- UI states for loading, success, empty, and error
- Repository pattern and caching in Flutter
- Pull-to-refresh and retry logic

## Screenshots
[!Output](![WhatsApp Image 2025-10-09 at 23 13 06_28c114f2](https://github.com/user-attachments/assets/73da953a-9321-49a4-8a83-75377e115e19)
[!Output](![WhatsApp Image 2025-10-09 at 23 12 24_2314a981](https://github.com/user-attachments/assets/42250635-9396-466a-b37e-98874db758b5)



