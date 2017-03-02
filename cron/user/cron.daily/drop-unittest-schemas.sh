#!/bin/bash
for schema in $(
	psql -U unittest -c "copy (select schema_name from information_schema.schemata where schema_name like 'unittest%') to stdout" 2>/dev/null
); do
	psql -U unittest -c "drop schema $schema cascade" >/dev/null
done

# also clear out old temporary files
rm -f \
    /tmp/eventcentral_and_tweaks.sql* \
    /tmp/EcSystemInformationTest* \
    /tmp/EcAttachmentEditUpdateFileTest* \
    /tmp/EcAttachmentFoldersCloudifyAttachmentTest* \
    /tmp/Code128BarcodeTest*
