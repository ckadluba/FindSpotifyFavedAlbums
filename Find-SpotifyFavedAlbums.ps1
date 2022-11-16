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
    $filteredAlbums = $response.items
    if ($ReleaseDateBegin)
    {
        $filteredAlbums = $filteredAlbums | Where-Object { $_.album.release_date -ge $ReleaseDateBegin }
    }
    if ($ReleaseDateEnd)
    {
        $filteredAlbums = $filteredAlbums | Where-Object { $_.album.release_date -le $ReleaseDateEnd }
    }
    if ($null -ne $OnlyReleaseTypes)
    {
        $filteredAlbums = $filteredAlbums | Where-Object { $OnlyReleaseTypes.Contains($_.album.album_type) }
    }

    # Output filtered batch as flattened objects
    foreach ($filteredAlbum in $filteredAlbums)
    {
        $flatAlbum = New-Object PSObject

        Add-Member -InputObject $flatAlbum -MemberType NoteProperty -Name ArtistName -Value $filteredAlbum.album.artists[0].name
        Add-Member -InputObject $flatAlbum -MemberType NoteProperty -Name AlbumName -Value $filteredAlbum.album.name
        Add-Member -InputObject $flatAlbum -MemberType NoteProperty -Name Label -Value $filteredAlbum.album.label
        Add-Member -InputObject $flatAlbum -MemberType NoteProperty -Name ReleaseDate -Value $filteredAlbum.album.release_date
        Add-Member -InputObject $flatAlbum -MemberType NoteProperty -Name AlbumType -Value $filteredAlbum.album.album_type
        Add-Member -InputObject $flatAlbum -MemberType NoteProperty -Name NumberTracks -Value $filteredAlbum.album.tracks.total

        Write-Output $flatAlbum
    }

    $offset += $limit
}

