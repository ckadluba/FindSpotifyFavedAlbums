[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $Year,

    [Parameter(Mandatory=$true)]
    [string]
    $AccessToken,

    [Parameter()]
    [switch]
    $OnlyAlbums,

    [Parameter()]
    [switch]
    $PrintMetadata
)

# Token can be generated with Spotify Dev console: https://spotify.dev/console/get-current-user-saved-albums/
# Scope: user-library-read

$authHeader = "Bearer " + $AccessToken
$limit = 20
$offset = 0

while ($true)
{
    $uri = "https://api.spotify.com/v1/me/albums?limit=" + $limit + "&offset=" + $offset
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers @{Accept = "application/json"; Authorization = $authHeader}
    if (($null -eq $response) -or ($response.items.Count -eq 0))
    {
        break
    }

    if ($OnlyAlbums.IsPresent -eq $true)
    {
        $albumsOfYear = $response.items | Where-Object { $_.album.release_date.Contains($Year) -and ($_.album.album_type -eq "album" -or $_.album.album_type -eq "compilation") }
    }
    else
    {
        $albumsOfYear = $response.items | Where-Object { $_.album.release_date.Contains($Year) }
    }

    foreach ($item in $albumsOfYear)
    {
        $album = $item.album
        $artist = $album.artists[0]
        $line = "$($artist.name) - $($album.name) ($($album.label))"
        if ($PrintMetadata.IsPresent -eq $true)
        {
            $line = "$line [released: $($album.release_date), type: $($album.album_type), tracks: $($album.tracks.total)]"
        }
        Write-Output $line
    }

    $offset += $limit
}

