for maillog in `ls /var/spool/mail/`; do
   tail -n 20000 /var/spool/mail/$maillog > /var/spool/mail/${maillog}2
   cat /var/spool/mail/${maillog}2 > /var/spool/mail/${maillog}
   /bin/rm -f /var/spool/mail/${maillog}2
done;
