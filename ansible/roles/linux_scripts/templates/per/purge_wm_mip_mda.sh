#!/bin/sh

echo "********* Beginning execution of wms/mda/mip temp file purge at `date` *********"
`showAliasesOnExecution=false;. /home/scopeadm/.SCPPprofile_per.ksh;cleanscpp 3 10`
`showAliasesOnExecution=false;. /home/scopeadm/.SCPPprofile_per_lmbatch.ksh;cleanscpp 3 10`

echo "********* Finished execution of wms/mda/mip temp file purge at `date` *********"
