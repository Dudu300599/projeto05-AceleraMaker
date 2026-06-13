       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROJBANC.
       AUTHOR. ACELERA.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ARQ-CLIENTE ASSIGN TO UT-S-CLIENTES.
           SELECT ARQ-TRANSAC ASSIGN TO UT-S-TRANSAC.
           SELECT ARQ-SAIDCLI ASSIGN TO UT-S-SAIDCLI.
           SELECT ARQ-RELATOR ASSIGN TO UT-S-RELATOR.
           SELECT ARQ-ERROS   ASSIGN TO UT-S-ERROS.
       DATA DIVISION.
       FILE SECTION.
       FD  ARQ-CLIENTE
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 44 CHARACTERS.
       01  REG-CLIENTE.
           05 CLI-ID         PIC X(05).
           05 CLI-NOME       PIC X(30).
           05 CLI-SALDO      PIC 9(09).
       FD  ARQ-TRANSAC
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 20 CHARACTERS.
       01  REG-TRANSACAO.
           05 TRX-CLI-ID     PIC X(05).
           05 TRX-ID         PIC 9(05).
           05 TRX-TIPO       PIC X(01).
           05 TRX-VALOR      PIC 9(09).
       FD  ARQ-SAIDCLI
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 44 CHARACTERS.
       01  REG-SAIDCLI       PIC X(44).
       FD  ARQ-RELATOR
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.
       01  REG-RELATOR       PIC X(80).
       FD  ARQ-ERROS
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.
       01  REG-ERROS         PIC X(80).
       WORKING-STORAGE SECTION.
       01  WS-CONTROLES.
           05 WS-EOF-CLI       PIC X(01) VALUE 'N'.
           05 WS-EOF-TRX       PIC X(01) VALUE 'N'.
       01  WS-ESTATISTICAS.
           05 WS-TOT-CLI       PIC 9(06) VALUE ZEROS.
           05 WS-TOT-TRX       PIC 9(06) VALUE ZEROS.
           05 WS-TOT-CRED      PIC 9(06) VALUE ZEROS.
           05 WS-TOT-DEB       PIC 9(06) VALUE ZEROS.
           05 WS-TOT-ERR       PIC 9(06) VALUE ZEROS.
       01  WS-CLI-ATUAL.
           05 WS-CLI-CRED      PIC 9(09) VALUE ZEROS.
           05 WS-CLI-DEB       PIC 9(09) VALUE ZEROS.
       01  WS-MENSAGENS.
           05 MSG-REL-CRED     PIC X(15) VALUE 'TOTAL CREDITOS:'.
           05 MSG-REL-DEB      PIC X(15) VALUE 'TOTAL DEBITOS: '.
           05 MSG-ERR-NENCONT  PIC X(39)
              VALUE 'ERRO: CLIENTE NAO ENCONTRADO - ID '.
           05 MSG-ERR-TIPO     PIC X(39)
              VALUE 'ERRO: TIPO DE TRANSACAO INVALIDO - ID '.
           05 MSG-ERR-VALOR    PIC X(39)
              VALUE 'ERRO: VALOR DE TRANSACAO INVALIDO - ID'.
           05 MSG-ERR-SALDO    PIC X(39)
              VALUE 'ERRO: SALDO INSUFICIENTE - ID '.
       01  WS-LINHA-RELAT.
           05 WS-REL-MSG       PIC X(15).
           05 FILLER           PIC X(01) VALUE ' '.
           05 WS-REL-VALOR     PIC 9(09).
           05 FILLER           PIC X(55) VALUE SPACES.
       01  WS-LINHA-ERRO.
           05 WS-ERR-MSG       PIC X(39).
           05 WS-ERR-ID        PIC 9(05).
           05 FILLER           PIC X(36) VALUE SPACES.
       01  WS-LINHA-CLI.
           05 WS-RCLI-MSG      PIC X(09) VALUE 'CLIENTE: '.
           05 WS-RCLI-ID       PIC 9(05).
           05 FILLER           PIC X(66) VALUE SPACES.
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
           OPEN INPUT ARQ-CLIENTE
                INPUT ARQ-TRANSAC
                OUTPUT ARQ-SAIDCLI
                OUTPUT ARQ-RELATOR
                OUTPUT ARQ-ERROS.
           PERFORM 0100-LER-CLIENTE.
           PERFORM 0200-LER-TRANSAC.
           PERFORM 0300-PROCESSA-MATCH
               UNTIL WS-EOF-CLI = 'Y' AND WS-EOF-TRX = 'Y'.
           PERFORM 0900-IMPRIME-ESTATISTICAS.
           CLOSE ARQ-CLIENTE ARQ-TRANSAC ARQ-SAIDCLI
                 ARQ-RELATOR ARQ-ERROS.
           STOP RUN.
       0100-LER-CLIENTE.
           READ ARQ-CLIENTE
               AT END
                   MOVE 'Y' TO WS-EOF-CLI
                   MOVE HIGH-VALUES TO CLI-ID.
       0200-LER-TRANSAC.
           READ ARQ-TRANSAC
               AT END
                   MOVE 'Y' TO WS-EOF-TRX
                   MOVE HIGH-VALUES TO TRX-CLI-ID.
       0300-PROCESSA-MATCH.
           IF CLI-ID = TRX-CLI-ID
               PERFORM 0400-TRATA-TRANSACAO
               PERFORM 0200-LER-TRANSAC
           ELSE
               IF CLI-ID < TRX-CLI-ID
                   PERFORM 0500-FECHA-CLIENTE
                   PERFORM 0100-LER-CLIENTE
               ELSE
                   PERFORM 0600-ERRO-CLIENTE
                   PERFORM 0200-LER-TRANSAC.


       0400-TRATA-TRANSACAO.
           ADD 1 TO WS-TOT-TRX.
           IF TRX-VALOR = 0
               PERFORM 0410-ERRO-VALOR
           ELSE
               IF TRX-TIPO = 'C'
                   ADD TRX-VALOR TO CLI-SALDO
                   ADD TRX-VALOR TO WS-CLI-CRED
                   ADD 1 TO WS-TOT-CRED
               ELSE
                   IF TRX-TIPO = 'D'
                       IF CLI-SALDO < TRX-VALOR
                           PERFORM 0420-ERRO-SALDO
                       ELSE
                           SUBTRACT TRX-VALOR FROM CLI-SALDO
                           ADD TRX-VALOR TO WS-CLI-DEB
                           ADD 1 TO WS-TOT-DEB
                   ELSE
                       PERFORM 0430-ERRO-TIPO.
       0410-ERRO-VALOR.
           ADD 1 TO WS-TOT-ERR.
           MOVE MSG-ERR-VALOR TO WS-ERR-MSG.
           MOVE TRX-CLI-ID TO WS-ERR-ID.
           WRITE REG-ERROS FROM WS-LINHA-ERRO.
       0420-ERRO-SALDO.
           ADD 1 TO WS-TOT-ERR.
           MOVE MSG-ERR-SALDO TO WS-ERR-MSG.
           MOVE TRX-CLI-ID TO WS-ERR-ID.
           WRITE REG-ERROS FROM WS-LINHA-ERRO.
       0430-ERRO-TIPO.
           ADD 1 TO WS-TOT-ERR.
           MOVE MSG-ERR-TIPO TO WS-ERR-MSG.
           MOVE TRX-CLI-ID TO WS-ERR-ID.
           WRITE REG-ERROS FROM WS-LINHA-ERRO.
       0500-FECHA-CLIENTE.
           IF WS-EOF-CLI = 'N'
               ADD 1 TO WS-TOT-CLI
               WRITE REG-SAIDCLI FROM REG-CLIENTE

               MOVE CLI-ID TO WS-RCLI-ID
               WRITE REG-RELATOR FROM WS-LINHA-CLI

               MOVE MSG-REL-CRED TO WS-REL-MSG
               MOVE WS-CLI-CRED TO WS-REL-VALOR
               WRITE REG-RELATOR FROM WS-LINHA-RELAT

               MOVE MSG-REL-DEB TO WS-REL-MSG
               MOVE WS-CLI-DEB TO WS-REL-VALOR
               WRITE REG-RELATOR FROM WS-LINHA-RELAT

               MOVE ZEROS TO WS-CLI-CRED
               MOVE ZEROS TO WS-CLI-DEB.
       0600-ERRO-CLIENTE.
           IF WS-EOF-TRX = 'N'
               ADD 1 TO WS-TOT-ERR
               MOVE MSG-ERR-NENCONT TO WS-ERR-MSG
               MOVE TRX-CLI-ID TO WS-ERR-ID
               WRITE REG-ERROS FROM WS-LINHA-ERRO.
       0900-IMPRIME-ESTATISTICAS.
           DISPLAY '****************************************'.
           DISPLAY 'ESTATISTICAS DE PROCESSAMENTO'.
           DISPLAY '****************************************'.
           DISPLAY 'CLIENTES PROCESSADOS.....: ' WS-TOT-CLI.
           DISPLAY 'TRANSACOES PROCESSADAS...: ' WS-TOT-TRX.
           DISPLAY 'CREDITOS PROCESSADOS.....: ' WS-TOT-CRED.
           DISPLAY 'DEBITOS PROCESSADOS......: ' WS-TOT-DEB.
           DISPLAY 'ERROS ENCONTRADOS........: ' WS-TOT-ERR.
           DISPLAY 'FIM DO PROCESSAMENTO'.
