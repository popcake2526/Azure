$companyRaw = "DDD"
$company = ($companyRaw -replace '\s+', '') -replace '[^a-zA-Z0-9]', ''
$copies = 100
$validYears = 5
$yearNow=(Get-Date).Year
$yearNow
$now = Get-Date
$notAfter = $now.AddYears($validYears)
New-Item -ItemType Directory -Path "C:\Certs" -Force | Out-Null
$pfxPassword = ConvertTo-SecureString "44216" -Force -AsPlainText


#Root
$cert = New-SelfSignedCertificate `
    -Type Custom `
    -KeySpec Signature `
    -Subject "CN=${company}P2SRoot${yearNow}" `
    -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 `
    -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyUsageProperty Sign `
    -KeyUsage CertSign `
    -NotAfter $notAfter

Export-Certificate `
    -Cert $cert `
    -FilePath "C:\Certs\${company}P2SRoot${yearNow}.cer"


for ($i = 1; $i -le $copies; $i++) {

    $dnsName = "${company}P2SChild${yearNow}-{0:D3}" -f $i

    $clientCert = New-SelfSignedCertificate `
        -Type Custom `
        -DnsName $dnsName `
        -KeySpec Signature `
        -Subject "CN=ClientCert-$dnsName" `
        -KeyExportPolicy Exportable `
        -HashAlgorithm sha256 `
        -KeyLength 2048 `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -Signer $cert `
        -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") `
        -NotAfter $notAfter

    $pfxPath = "C:\Certs\$dnsName.pfx"

    Export-PfxCertificate `
        -Cert $clientCert `
        -FilePath $pfxPath `
        -Password $pfxPassword
}