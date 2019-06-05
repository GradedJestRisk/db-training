CREATE OR REPLACE PROCEDURE prc_mail (p_message IN VARCHAR2 ) IS


BEGIN

 dbms_output.put_line('Envoi du mail ..');
 
  utl_mail.send (
      
    sender       => 'pierre.top.sopra-steria@cgifinance.fr',
    recipients   => 'pierre.top.sopra-steria@cgifinance.fr',
    cc           => NULL,
    bcc          => NULL,
    subject      => 'Test: sujet',
    message      => p_message, --'Test: objet',
    mime_type    => 'text/html; charset=WE8ISO8859P1',
    priority     => 1
    
  );
   

END prc_mail;
/
