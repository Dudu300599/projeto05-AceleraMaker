//HERC01A JOB (SYS),'PROJBANC',CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1)
//*---------------------------------------------------------*
//* PASSO 0: LIMPEZA DE ARQUIVOS ANTERIORES
//*---------------------------------------------------------*
//LIMPA    EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE HERC01.CLIENTES.OUT
  DELETE HERC01.RELATOR.TXT
  DELETE HERC01.ESTAT.TXT
  DELETE HERC01.ERROS.TXT
  SET MAXCC = 0
//*---------------------------------------------------------*
//* PASSO 1: ORDENAR ARQUIVO DE CLIENTES
//*---------------------------------------------------------*
//SORTCLI  EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTLIB  DD DSN=SYS1.SORTLIB,DISP=SHR
//SORTIN   DD DSN=HERC01.CLIENTES.TXT,DISP=SHR
//SORTOUT  DD DSN=&&CLIENTES,
//            DISP=(NEW,PASS),UNIT=SYSDA,SPACE=(CYL,(1,1)),
//            DCB=(RECFM=FB,LRECL=44,BLKSIZE=4400)
//SYSIN    DD *
  SORT FIELDS=(1,5,CH,A)
/*
//*---------------------------------------------------------*
//* PASSO 2: ORDENAR ARQUIVO DE TRANSACOES
//*---------------------------------------------------------*
//SORTTRX  EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTLIB  DD DSN=SYS1.SORTLIB,DISP=SHR
//SORTIN   DD DSN=HERC01.TRANSACO.TXT,DISP=SHR
//SORTOUT  DD DSN=&&TRANSAC,
//            DISP=(NEW,PASS),UNIT=SYSDA,SPACE=(CYL,(1,1)),
//            DCB=(RECFM=FB,LRECL=20,BLKSIZE=2000)
//SYSIN    DD *
  SORT FIELDS=(1,5,CH,A,6,5,CH,A)
/*
//*---------------------------------------------------------*
//* PASSO 3: COMPILAR E EXECUTAR O COBOL
//*---------------------------------------------------------*
//STEP1    EXEC COBUCLG
//COB.SYSIN DD DSN=HERC01.COBOL(PROJBANC),DISP=SHR
//GO.CLIENTES DD DSN=&&CLIENTES,DISP=(OLD,DELETE)
//GO.TRANSAC  DD DSN=&&TRANSAC,DISP=(OLD,DELETE)
//GO.SAIDCLI  DD DSN=HERC01.CLIENTES.OUT,
//            DISP=(NEW,CATLG,DELETE),UNIT=SYSDA,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FB,LRECL=44,BLKSIZE=440)
//GO.RELATOR  DD DSN=HERC01.RELATOR.TXT,
//            DISP=(NEW,CATLG,DELETE),UNIT=SYSDA,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
//GO.ERROS    DD DSN=HERC01.ERROS.TXT,
//            DISP=(NEW,CATLG,DELETE),UNIT=SYSDA,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
//GO.SYSOUT   DD DSN=HERC01.ESTAT.TXT,
//            DISP=(NEW,CATLG,DELETE),UNIT=SYSDA,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FBA,LRECL=121,BLKSIZE=1210)
