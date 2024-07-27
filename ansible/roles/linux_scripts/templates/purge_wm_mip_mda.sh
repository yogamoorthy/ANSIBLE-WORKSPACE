#!/bin/sh


echo "********* Beginning execution of wms/mda/mip temp file purge at `date` *********"
`showAliasesOnExecution=false;. /home/scopeadm/.SCPPprofile_wms.ksh;cleanscpp 4 30`

echo "********* Finished execution of wms/mda/mip temp file purge at `date` *********"
