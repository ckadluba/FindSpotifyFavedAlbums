[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $AccessToken,

    [Parameter()]
    [string]
    $ReleaseDateBegin,

    [Parameter()]
    [string]
    $ReleaseDateEnd,

    [Parameter()]
    [System.String[]]
    $OnlyReleaseTypes
)

$authHeader = "Bearer " + $AccessToken
$limit = 20
$offset = 0

while ($true)
{
    # Query batch
    Write-Verbose "Sending request, offset=$offset ..."
    $uri = "https://api.spotify.com/v1/me/albums?limit=" + $limit + "&offset=" + $offset
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers @{Accept = "application/json"; Authorization = $authHeader}
    if (($null -eq $response) -or ($response.items.Count -eq 0))
    {
        break
    }

    # Filter result
    $albumsOfYear = $response.items
    if ($ReleaseDateBegin)
    {
        $albumsOfYear = $albumsOfYear | Where-Object { $_.album.release_date -ge $ReleaseDateBegin }
    }
    if ($ReleaseDateEnd)
    {
        $albumsOfYear = $albumsOfYear | Where-Object { $_.album.release_date -le $ReleaseDateEnd }
    }
    if ($null -ne $OnlyReleaseTypes)
    {
        $albumsOfYear = $albumsOfYear | Where-Object { $OnlyReleaseTypes.Contains($_.album.album_type) }
    }

    # Output filtered batch as flattened objects
    foreach ($item in $albumsOfYear)
    {
        $album = New-Object PSObject

        Add-Member -InputObject $album -MemberType NoteProperty -Name ArtistName -Value $item.album.artists[0].name
        Add-Member -InputObject $album -MemberType NoteProperty -Name AlbumName -Value $item.album.name
        Add-Member -InputObject $album -MemberType NoteProperty -Name Label -Value $item.album.label
        Add-Member -InputObject $album -MemberType NoteProperty -Name ReleaseDate -Value $item.album.release_date
        Add-Member -InputObject $album -MemberType NoteProperty -Name AlbumType -Value $item.album.album_type
        Add-Member -InputObject $album -MemberType NoteProperty -Name NumberTracks -Value $item.album.tracks.total

        Write-Output $album
    }

    $offset += $limit
}

