# Roblox Boss Chase and Mythic Pets Integration Kit

The game place and supporting integration files are included in this repository.

The Mythic Pets animation archive is stored as three consecutive binary parts because the reconstructed ZIP exceeds GitHub's per-file size limit. Reassemble the parts in order before extracting.

## Reassemble on Windows (PowerShell)

Run from this directory:

~~~powershell
$parts = Get-ChildItem -File 'Mythic_Pets_NEW_RIGS_440_Animations.zip.part*' | Sort-Object Name
$output = [System.IO.File]::Create('Mythic_Pets_NEW_RIGS_440_Animations.zip')
foreach ($part in $parts) {
  $input = [System.IO.File]::OpenRead($part.FullName)
  $input.CopyTo($output)
  $input.Dispose()
}
$output.Dispose()
~~~

Then extract 'Mythic_Pets_NEW_RIGS_440_Animations.zip'.
