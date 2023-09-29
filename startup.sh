#! /bin/bash
cd spamassassin-dqs/3.4.1+ \
      && sed -i -e "s/your_DQS_key/$SPAMHAUS_DQS_KEY/g" sh.cf \
      && sed -i -e "s/your_DQS_key/$SPAMHAUS_DQS_KEY/g" sh_hbl.cf \
      && sed -i -e "s/<config_directory>/\/etc\/mail\/spamassassin/g" sh.pre \
      && cp SH.pm /etc/mail/spamassassin \
      && cp sh.cf /etc/mail/spamassassin \
      && cp sh_scores.cf /etc/mail/spamassassin \
      && cp sh.pre /etc/mail/spamassassin
# Uncomment if HBL (paid) enabled
# && cp sh_hbl.cf /etc/mail/spamassassin
# && cp sh_hbl_scores.cf /etc/mail/spamassassin

gunicorn -k uvicorn.workers.UvicornWorker app:app