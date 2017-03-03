#!/bin/bash
psql -U postgres <<'EOSQL'
drop database unittest;
create database unittest;
grant all on database unittest to unittest;

EOSQL

# also clear out old temporary files
rm -f \
    /tmp/eventcentral_and_tweaks.sql* \
    /tmp/EcSystemInformationTest* \
    /tmp/EcAttachmentEditUpdateFileTest* \
    /tmp/EcAttachmentFoldersCloudifyAttachmentTest* \
    /tmp/Code128BarcodeTest*
