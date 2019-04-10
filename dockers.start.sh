docker run --rm --name hostA1 -h hostA1 --network netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostA2 -h hostA2 --network netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB1 -h hostB1 --network netB --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB2 -h hostB2 --network netB --privileged -d edtasixm11/net18:nethost
docker run --rm --name ldap -h ldap --network netDMZ --privileged -d edtasixm06/ldapserver:18group
docker run --rm --name hostDMZ1 -h hostDMZ1 --network netDMZ --privileged -d edtasixm11/net18:nethost

