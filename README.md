# FindSpotifyFavedAlbums

A PowerShell script to query the faved albums of a user from the Spotify Web API.

Query parameters are time range of release dates and types of releases. The data returned by the script is a flat list of objects containing only a selection of all the properties that are returned by the API for an album.

Although the script and API contains the term "album", it returns any type of releases from the users faved list but not songs that were faved directly.

# Usage

Get all faved albums of type `single` released since March 2022.

```powershell
.\Find-SpotifyFavedAlbums.ps1 -AccessToken "<your-token>" -ReleaseDateBegin "2022-03-01" -OnlyReleaseTypes "single"
```

Get all faved albums of any type released until end of January 2020 in CSV format.

```powershell
.\Find-SpotifyFavedAlbums.ps1 -AccessToken "<your-token>" -ReleaseDateEnd "2020-01-31" | ConvertTo-Csv
```

Get title, artist and label of faved albums of type `album` or `compilation` released in 2022 as human readable list.

```powershell
.\Find-SpotifyFavedAlbums.ps1 -AccessToken "<your-token>" -ReleaseDateBegin "2022-01-01" -ReleaseDateEnd "2022-12-31" -OnlyReleaseTypes @("album", "compilation") | ForEach-Object { "$($_.ArtistName) - $($_.AlbumName) ($($_.Label))" }
```

# Parameters

* AccessToken  
  Spotify OAuth token (mandatory).  
  See [Prerequisites](#prerequisites) for details.
* ReleaseDateBegin  
  Begin (inclusive) of the release date range (optional).
* ReleaseDateEnd  
  End (inclusive) of the release date range (optional).
* OnlyReleaseTypes  
  List of release types to be returned (optional).  
  Allowed valued include "album", "single" and "compilation". Refer to Spotify API reference for allowed values (https://developer.spotify.com/documentation/web-api/reference/#/).

# Prerequisites

* PowerShell 7
* Spotify developer account  
  See https://developer.spotify.com/documentation/web-api/quick-start for details.
* Spotify OAuth token   
  Select "Get token" at any method on the dev console (https://spotify.dev/console). Scopes must include `user-library-read`.

