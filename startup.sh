#! /bin/bash
cd spamassassin-dqs/4.0.0+ \
      && sed -i -e "s/your_DQS_key/$SPAMHAUS_DQS_KEY/g" sh.cf \
      && sed -i -e "s/your_DQS_key/$SPAMHAUS_DQS_KEY/g" sh_hbl.cf \
      && sed -i -e "s/<config_directory>/\/etc\/mail\/spamassassin/g" sh.pre \ 
      && cp sh.cf /etc/mail/spamassassin \
      && cp sh_scores.cf /etc/mail/spamassassin \
      && cp sh_hbl.cf /etc/mail/spamassassin \
      && cp sh_hbl_scores.cf /etc/mail/spamassassin \
      && cp SH.pm /etc/mail/spamassassin \
      && cp sh.pre /etc/mail/spamassassin 
