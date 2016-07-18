library(sendmailR)

sendmail_options(smtpServer="ASPMX.L.GOOGLE.COM")

from = "<madridauditamadrid@gmail.com>"
to = "<asalber@gmail.com>"
subject <- "Prueba de envío de fichas de ilegitimidad"
body <- "Prueba de fichas"                     
#control=list(smtpServer="ASPMX.L.GOOGLE.COM")

sendmail(from=from,to=to,subject=subject,msg=body)


library(mailR)
sender <- "asalber@gmail.com"
recipients <- c("asalber@gmail.com")
send.mail(from = sender,
          to = recipients,
          subject="Subject of the email",
          body = "Body of the email",
          smtp = list(host.name = "smtp.gmail.com", port = 465, 
                      user.name="asalber@gmail.com", passwd="pzdhzsducwjelxyi", ssl=TRUE),
          authenticate = TRUE,
          send = TRUE)


send.mail(from = "asalber@gmail.com",
          to = c("asalber@gmail.com"),
          subject = "Subject of the email",
          body = "Body of the email",
          smtp = list(host.name = "aspmx.l.google.com", port = 25),
          authenticate = FALSE,
          send = TRUE)