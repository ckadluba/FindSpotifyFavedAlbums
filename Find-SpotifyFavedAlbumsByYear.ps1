# Token generated with Spotify Dev console: https://spotify.dev/console/get-current-user-saved-albums/
# Scope: user-library-read
$token = "BQBHFwtbKvN6p55bAh1UesuDYhBeKTTIu5CIT7hGBpWXkGGfuoPbkedvaskLpbnu44Tj-m5DAZZo-wcBcIgHXeNjBRvUASSbVQK42Fj8UoWL2ojzMuFpVtUl5PyjhlKNb5RDy3BO5uhooYgwGGr0Y6G56gIyB9_t6dPA9yjU_9wGNx7XtyvHSYBk"
$authHeader = "Bearer " + $token

$year = "2022"
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

    $albumsOfYear = $response.items | Where-Object { $_.album.release_date.Contains($year) }
    foreach ($item in $albumsOfYear)
    {
        $album = $item.album
        $artist = $album.artists[0]
        $line = "$($artist.name) - $($album.name) (released: $($album.release_date), tracks: $($album.tracks.total))"
        Write-Output $line
    }

    $offset += $limit
}

