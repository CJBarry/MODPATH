C MODPATH Version 3.00 (V3, Release 2, 6-2000)
C Changes:
C   No change from previous release: (V3, Release 1, 9-94)
C***** SUBROUTINES *****
C     DRNINP
C     EVTINP
C     GHBINP
C     RCHINP
C     RIVINP
C     STRINP
C     WELINP
C***********************
 
C***** SUBROUTINE *****
      SUBROUTINE DRNINP (IU,QX,QY,QZ,BUFF,IBOUND,NCOL,NROW,NLAY,
     1NCP1,NRP1,NLP1,QSS,IBUFF,DELR,DELC,I7,ISILNT,KPER,KSTP,IUCBC,
     2NDRNSV,ITMPO,DRNSV,NEWPER,IREADQ)
C
      DIMENSION QX(NCP1,NROW,NLAY),QY(NCOL,NRP1,NLAY),
     1QZ(NCOL,NROW,NLP1),IBOUND(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     2QSS(NCOL,NROW,NLAY),IBUFF(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     3DRNSV(NDRNSV)
      CHARACTER*80 LINE
C
C... CHECK TO SEE IF IT IS A NEW STRESS PERIOD. IF SO, READ ITMP.
      IF(NEWPER.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,ITMP,RDUMMY,I7,IU)
 
C... ITMP CANNOT BE < 0 FOR THE FIRST STRESS PERIOD
      IF(ITMP.LT.0 .AND. KPER.EQ.1) THEN
      WRITE(I7,*) 'ITMP < 0 FOR STRESS PERIOD 1. RUN STOPPED.'
      STOP
      END IF
 
      ELSE
 
C... IF NOT A NEW STRESS PERIOD, SET ITMP= -1 AND PROCEED
      ITMP= -1
      END IF
 
C... ITMP < 0 MEANS USE OLD VALUES
      IF(ITMP.LT.0) THEN
      IN=0
      ITMP=ITMPO
 
      ELSE
 
C... ITMP >= 0 MEANS DISCARD OLD VALUES AND GET NEW ONES IF ITMP > 0
      IN=1
      ITMPO=ITMP
      END IF
 
      IF(ITMP.LE.0) RETURN
 
      DO 10 K=1,NLAY
      DO 10 I=1,NROW
      DO 10 J=1,NCOL
10    IBUFF(J,I,K)=0
 
      IERR=0
      DO 20 N=1,ITMP
      NN= 4*(N-1)
      IF(IN.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,K,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,I,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,J,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,H,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,C,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,IFACE,RDUMMY,I7,IU)
      DRNSV(NN+1)=K
      DRNSV(NN+2)=I
      DRNSV(NN+3)=J
      DRNSV(NN+4)=IFACE
      ELSE
      K= DRNSV(NN+1)
      I= DRNSV(NN+2)
      J= DRNSV(NN+3)
      IFACE= DRNSV(NN+4)
      END IF
C
      IB=IBOUND(J,I,K)
      IF(IB.LE.0) THEN
      IF(IB.EQ.0) WRITE(I7,5030) J,I,K
      IF(IB.LT.0) WRITE(I7,5040) J,I,K
5030  FORMAT (' A DRAIN WAS SPECIFIED FOR INACTIVE CELL (J,I,K) =',
     12(I4,','),I4)
5040  FORMAT (' A DRAIN WAS SPECIFIED FOR CONSTANT HEAD CELL (J,I,K) = (
     1',I3,',',I3,',',I3,')')
      IERR=IERR+1
      GO TO 20
      END IF
C
      IF(IBUFF(J,I,K).EQ.1 .OR. IREADQ.EQ.0) GO TO 20
      IBUFF(J,I,K)=1
      CALL ADDQ (BUFF(J,I,K),QSS,QX,QY,QZ,DELR,DELC,IBOUND,IB,NCOL,NROW,
     1 NLAY,NCP1,NRP1,NLP1,J,I,K,IFACE,'DRAIN',I7)
20    CONTINUE
C
      IF (IERR.GT.0.AND.ISILNT.EQ.0) THEN
      WRITE (*,5046) IERR
5046  FORMAT(' DRAINS WERE SPECIFIED FOR ',I4,' INACTIVE OR CONSTANT HEA
     1D CELLS')
      WRITE (*,*) 'A LIST IS PROVIDED IN THE "SUMMARY.PTH"  FILE'
      END IF
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE EVTINP(IU,QZ,BUFF,NCOL,NROW,NLAY,NLP1,QSS,IBOUND,I7,
     1                  ISILNT,KPER,KSTP,IEVTTP,IUCBC,IFIRST)
C
      DIMENSION QZ(NCOL,NROW,NLP1),BUFF(NCOL,NROW,NLAY),
     1QSS(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY)
      CHARACTER*24 ANAME
      CHARACTER*80 LINE
C
      IF(IEVTTP.EQ.0 .AND. NLAY.GT.1 .AND. IFIRST.EQ.1) THEN
      IF(ISILNT.EQ.0) WRITE(*,*) 'MODEL IS MULTI-LAYER, BUT ET WILL BE T
     1REATED AS A DISTRIBUTED SINK TERM'
      WRITE(I7,*) 'MODEL IS MULTI-LAYER, BUT ET WILL BE TREATED AS A DIS
     1TRIBUTED SINK TERM'
      END IF
      IFIRST=0
 
      DO 10 I=1,NROW
      DO 10 J=1,NCOL
 
C--- FOR THIS (J,I), FIND THE LAYER THAT CONTAINS THE ET.
      K=0
      DO 20 KK=1,NLAY
      IF(BUFF(J,I,KK).LT.0.0) THEN
        K=KK
        GO TO 25
      END IF
20    CONTINUE
25    CONTINUE
C--- IF ET=0, SKIP TO NEXT (J,I)
      IF(K.EQ.0) GO TO 10
 
      IF(IEVTTP.GT.0) THEN
      CALL FACTYP (K,1,J,I,K-1,NBD,IBOUND,NCOL,NROW,NLAY,J,I,K,6,
     1            'EVAPOTRANSPIRATION',I7)
        IF (NBD.EQ.1) THEN
          QZ(J,I,K)= QZ(J,I,K) - BUFF(J,I,K)
        ELSE
          QSS(J,I,K)=QSS(J,I,K) + BUFF(J,I,K)
          IF(BUFF(J,I,K).LT.0.0.AND.IBOUND(J,I,K).GT.0.AND.
     1      IBOUND(J,I,K).LT.1000) IBOUND(J,I,K)= 1000*IBOUND(J,I,K)
        END IF
      ELSE
        QSS(J,I,K)=QSS(J,I,K) + BUFF(J,I,K)
        IF(BUFF(J,I,K).LT.0.0.AND.IBOUND(J,I,K).GT.0.AND.
     1    IBOUND(J,I,K).LT.1000) IBOUND(J,I,K)= 1000*IBOUND(J,I,K)
      END IF
10    CONTINUE
 
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE GHBINP (IU,QX,QY,QZ,BUFF,IBOUND,NCOL,NROW,NLAY,
     1NCP1,NRP1,NLP1,QSS,IBUFF,DELR,DELC,I7,ISILNT,KPER,KSTP,IUCBC,
     2NGHBSV,ITMPO,GHBSV,NEWPER,IREADQ)
C
      DIMENSION QX(NCP1,NROW,NLAY),QY(NCOL,NRP1,NLAY),
     1QZ(NCOL,NROW,NLP1),IBOUND(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     2QSS(NCOL,NROW,NLAY),IBUFF(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     3GHBSV(NGHBSV)
      CHARACTER*80 LINE
C
C... CHECK TO SEE IF IT IS A NEW STRESS PERIOD. IF SO, READ ITMP.
      IF(NEWPER.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,ITMP,RDUMMY,I7,IU)
 
C... ITMP CANNOT BE < 0 FOR THE FIRST STRESS PERIOD
      IF(ITMP.LT.0 .AND. KPER.EQ.1) THEN
      WRITE(I7,*) 'ITMP < 0 FOR STRESS PERIOD 1. RUN STOPPED.'
      STOP
      END IF
 
      ELSE
 
C... IF NOT A NEW STRESS PERIOD, SET ITMP= -1 AND PROCEED
      ITMP= -1
      END IF
 
C... ITMP < 0 MEANS USE OLD VALUES
      IF(ITMP.LT.0) THEN
      IN=0
      ITMP=ITMPO
 
      ELSE
 
C... ITMP >= 0 MEANS DISCARD OLD VALUES AND GET NEW ONES IF ITMP > 0
      IN=1
      ITMPO=ITMP
      END IF
 
      IF(ITMP.LE.0) RETURN
 
      DO 10 K=1,NLAY
      DO 10 I=1,NROW
      DO 10 J=1,NCOL
10    IBUFF(J,I,K)=0
 
      IERR=0
      DO 20 N=1,ITMP
      NN= 4*(N-1)
      IF(IN.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,K,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,I,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,J,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,H,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,C,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,IFACE,RDUMMY,I7,IU)
      GHBSV(NN+1)=K
      GHBSV(NN+2)=I
      GHBSV(NN+3)=J
      GHBSV(NN+4)=IFACE
      ELSE
      K= GHBSV(NN+1)
      I= GHBSV(NN+2)
      J= GHBSV(NN+3)
      IFACE= GHBSV(NN+4)
      END IF
C
      IB=IBOUND(J,I,K)
      IF(IB.LE.0) THEN
      IF(IB.EQ.0) WRITE(I7,5030) J,I,K
      IF(IB.LT.0) WRITE(I7,5040) J,I,K
5030  FORMAT (' A GHB WAS SPECIFIED FOR INACTIVE CELL (J,I,K) =',
     12(I4,','),I4)
5040  FORMAT (' A GHB WAS SPECIFIED FOR CONSTANT HEAD CELL (J,I,K) = ('
     1,I3,',',I3,',',I3,')')
      IERR=IERR+1
      GO TO 20
      END IF
C
      IF(IBUFF(J,I,K).EQ.1 .OR. IREADQ.EQ.0) GO TO 20
      IBUFF(J,I,K)=1
      CALL ADDQ (BUFF(J,I,K),QSS,QX,QY,QZ,DELR,DELC,IBOUND,IB,NCOL,NROW,
     1 NLAY,NCP1,NRP1,NLP1,J,I,K,IFACE,'GHB',I7)
20    CONTINUE
C
      IF (IERR.GT.0.AND.ISILNT.EQ.0) THEN
      WRITE (*,5046) IERR
5046  FORMAT(' GHBS WERE SPECIFIED FOR ',I4,' INACTIVE OR CONSTANT HEAD
     1CELLS')
      WRITE (*,*) 'A LIST IS PROVIDED IN THE "SUMMARY.PTH"  FILE'
      END IF
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE RCHINP (IU,QZ,RECHSV,IRCHSV,HEAD,IBOUND,DELR,DELC,
     1NCOL,NROW,NLP1,NLAY,QSS,I7,ISILNT,IRCHTP,NRCHOP,KPER,NEWPER,
     2IREADQ,HDRY)
C
      DIMENSION QZ(NCOL,NROW,NLP1),RECHSV(NCOL,NROW),IRCHSV(NCOL,NROW),
     1HEAD(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     2QSS(NCOL,NROW,NLAY)
C
      CHARACTER*24 ANAME
      CHARACTER*80 LINE
C
      IF(IRCHTP.EQ.0.AND.NLAY.GT.1.AND.NEWPER.EQ.1)THEN
      IF(ISILNT.EQ.0)WRITE(*,*) 'MODEL IS MULTI-LAYER, BUT RECHARGE WILL
     1 BE TREATED AS A DISTRIBUTED SOURCE TERM'
      WRITE(I7,*) 'MODEL IS MULTI-LAYER, BUT RECHARGE WILL BE TREATED AS
     1 A DISTRIBUTED SOURCE TERM'
      END IF
 
C... CHECK TO SEE IF IT IS A NEW STRESS PERIOD. IF SO, READ FLAGS
      IF(NEWPER.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,INRECH,RDUMMY,I7,IU)
      IF(NRCHOP.EQ.2) THEN
        CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,INIRCH,RDUMMY,I7,IU)
      ELSE
        INIRCH=0
      END IF
 
C... FLAGS CANNOT BE < 0 FOR FIRST STRESS PERIOD
      IF(INRECH.LT.0 .AND. KPER.EQ.1) THEN
      WRITE(I7,*) 'INRECH < 0 FOR STRESS PERIOD 1. RUN STOPPED.'
      STOP
      END IF
      IF(INIRCH.LT.0 .AND. KPER.EQ.1 .AND. NRCHOP.EQ.2) THEN
      WRITE(I7,*) 'INIRCH < 0 FOR STRESS PERIOD 1. RUN STOPPED.'
      STOP
      END IF
 
      ELSE
 
C... IF NOT A NEW STRESS PERIOD, SET FLAGS TO -1 AND PROCEED.
      INRECH= -1
      INIRCH= -1
      END IF
 
C... INRECH >= 0 MEANS RECHSV ARRAY IS READ THIS TIME THROUGH
      IF(INRECH.GE.0) THEN
      ANAME= 'RECHARGE RATE'
      CALL U2DREL(RECHSV,ANAME,NROW,NCOL,0,IU,I7)
      END IF
 
C... IF RECHARGE OPTION IS 2, CHECK TO SEE IF IRCHSV ARRAY SHOULD BE
C    READ THIS TIME THROUGH
      IF(NRCHOP.EQ.2) THEN
      IF(INIRCH.GE.0) THEN
      ANAME= ' RECHARGE LAYER'
      CALL U2DINT(IRCHSV,ANAME,NROW,NCOL,0,IU,I7)
      END IF
 
      END IF
 
      IF(IREADQ.NE.0) THEN
      IF(NRCHOP.EQ.1) THEN
      DO 10 I=1,NROW
      DO 10 J=1,NCOL
      IF(IBOUND(J,I,1).LE.0.OR.HEAD(J,I,1).GT.1.0E+29) GO TO 10
      IF(IRCHTP.GT.0) THEN
      QZ(J,I,1)= QZ(J,I,1) - RECHSV(J,I)*DELR(J)*DELC(I)
      ELSE
      QSS(J,I,1)=QSS(J,I,1) + RECHSV(J,I)*DELR(J)*DELC(I)
      END IF
10    CONTINUE
      END IF
      IF(NRCHOP.EQ.2) THEN
      DO 20 I=1,NROW
      DO 20 J=1,NCOL
      K= IRCHSV(J,I)
      IF(IBOUND(J,I,K).LE.0.OR.HEAD(J,I,K).EQ.HDRY) GO TO 20
      IF(IRCHTP.GT.0) THEN
      CALL FACTYP (K,1,J,I,K-1,NBD,IBOUND,NCOL,NROW,NLAY,J,I,K,6,
     1            'RECHARGE',I7)
      IF (NBD.EQ.1) THEN
      QZ(J,I,K)= QZ(J,I,K) - RECHSV(J,I)*DELR(J)*DELC(I)
      ELSE
      QSS(J,I,K)=QSS(J,I,K) + RECHSV(J,I)*DELR(J)*DELC(I)
      END IF
      ELSE
      QSS(J,I,K)=QSS(J,I,K) + RECHSV(J,I)*DELR(J)*DELC(I)
      END IF
20    CONTINUE
      END IF
      IF(NRCHOP.EQ.3) THEN
      DO 50 I=1,NROW
      DO 50 J=1,NCOL
      DO 30 K=1,NLAY
      KK=K
      IF(IBOUND(J,I,K).LT.0) GO TO 50
      IF(IBOUND(J,I,K).EQ.0.OR.HEAD(J,I,K).EQ.HDRY) GO TO 30
      GO TO 40
30    CONTINUE
      GO TO 50
40    CONTINUE
      IF(IRCHTP.GT.0) THEN
      QZ(J,I,KK)= QZ(J,I,KK) - RECHSV(J,I)*DELC(I)*DELR(J)
      ELSE
      QSS(J,I,KK)=QSS(J,I,KK) + RECHSV(J,I)*DELC(I)*DELR(J)
      END IF
50    CONTINUE
      END IF
      END IF
C
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE RIVINP (IU,QX,QY,QZ,BUFF,IBOUND,NCOL,NROW,NLAY,
     1NCP1,NRP1,NLP1,QSS,IBUFF,DELR,DELC,I7,ISILNT,KPER,KSTP,IUCBC,
     2NRIVSV,ITMPO,RIVSV,NEWPER,IREADQ)
C
      DIMENSION QX(NCP1,NROW,NLAY),QY(NCOL,NRP1,NLAY),
     1QZ(NCOL,NROW,NLP1),IBOUND(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     2QSS(NCOL,NROW,NLAY),IBUFF(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     3RIVSV(NRIVSV)
      CHARACTER*80 LINE
C
C... CHECK TO SEE IF IT IS A NEW STRESS PERIOD. IF SO, READ ITMP.
      IF(NEWPER.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,ITMP,RDUMMY,I7,IU)
 
C... ITMP CANNOT BE < 0 FOR THE FIRST STRESS PERIOD
      IF(ITMP.LT.0 .AND. KPER.EQ.1) THEN
      WRITE(I7,*) 'ITMP < 0 FOR STRESS PERIOD 1. RUN STOPPED.'
      STOP
      END IF
 
      ELSE
 
C... IF NOT A NEW STRESS PERIOD, SET ITMP= -1 AND PROCEED
      ITMP= -1
      END IF
 
C... ITMP < 0 MEANS USE OLD VALUES
      IF(ITMP.LT.0) THEN
      IN=0
      ITMP=ITMPO
 
      ELSE
 
C... ITMP >= 0 MEANS DISCARD OLD VALUES AND GET NEW ONES IF ITMP > 0
      IN=1
      ITMPO=ITMP
      END IF
 
      IF(ITMP.LE.0) RETURN
 
      DO 10 K=1,NLAY
      DO 10 I=1,NROW
      DO 10 J=1,NCOL
10    IBUFF(J,I,K)=0
 
      IERR=0
      DO 20 N=1,ITMP
      NN= 4*(N-1)
      IF(IN.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,K,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,I,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,J,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,H,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,C,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,E,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,IFACE,RDUMMY,I7,IU)
      RIVSV(NN+1)=K
      RIVSV(NN+2)=I
      RIVSV(NN+3)=J
      RIVSV(NN+4)=IFACE
      ELSE
      K= RIVSV(NN+1)
      I= RIVSV(NN+2)
      J= RIVSV(NN+3)
      IFACE= RIVSV(NN+4)
      END IF
C
      IB=IBOUND(J,I,K)
      IF(IB.LE.0) THEN
      IF(IB.EQ.0) WRITE(I7,5030) J,I,K
      IF(IB.LT.0) WRITE(I7,5040) J,I,K
5030  FORMAT (' A RIVER WAS SPECIFIED FOR INACTIVE CELL (J,I,K) =',
     12(I4,','),I4)
5040  FORMAT (' A RIVER WAS SPECIFIED FOR CONSTANT HEAD CELL (J,I,K) = (
     1',I3,',',I3,',',I3,')')
      IERR=IERR+1
      GO TO 20
      END IF
C
      IF(IBUFF(J,I,K).EQ.1 .OR. IREADQ.EQ.0) GO TO 20
      IBUFF(J,I,K)=1
      CALL ADDQ (BUFF(J,I,K),QSS,QX,QY,QZ,DELR,DELC,IBOUND,IB,NCOL,NROW,
     1 NLAY,NCP1,NRP1,NLP1,J,I,K,IFACE,'RIVER',I7)
20    CONTINUE
C
      IF (IERR.GT.0.AND.ISILNT.EQ.0) THEN
      WRITE (*,5046) IERR
5046  FORMAT(' RIVERS WERE SPECIFIED FOR ',I4,' INACTIVE OR CONSTANT HEA
     1D CELLS')
      WRITE (*,*) 'A LIST IS PROVIDED IN THE "SUMMARY.PTH"  FILE'
      END IF
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE STRINP (IU,QX,QY,QZ,BUFF,IBOUND,NCOL,NROW,NLAY,
     1NCP1,NRP1,NLP1,QSS,IBUFF,DELR,DELC,I7,ISILNT,KPER,KSTP,IUCBC,
     2NSTRSV,ITMPO,STRSV,NEWPER,IREADQ)
C
      DIMENSION QX(NCP1,NROW,NLAY),QY(NCOL,NRP1,NLAY),
     1QZ(NCOL,NROW,NLP1),IBOUND(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     2QSS(NCOL,NROW,NLAY),IBUFF(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     3STRSV(NSTRSV)
      CHARACTER*132 LINE
C
C... CHECK TO SEE IF IT IS A NEW STRESS PERIOD. IF SO, READ ITMP.
      IF(NEWPER.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,ITMP,RDUMMY,I7,IU)
 
C... ITMP CANNOT BE < 0 FOR THE FIRST STRESS PERIOD
      IF(ITMP.LT.0 .AND. KPER.EQ.1) THEN
      WRITE(I7,*) 'ITMP < 0 FOR STRESS PERIOD 1. RUN STOPPED.'
      STOP
      END IF
 
      ELSE
 
C... IF NOT A NEW STRESS PERIOD, SET ITMP= -1 AND PROCEED
      ITMP= -1
      END IF
 
C... ITMP < 0 MEANS USE OLD VALUES
      IF(ITMP.LT.0) THEN
      IN=0
      ITMP=ITMPO
 
      ELSE
 
C... ITMP >= 0 MEANS DISCARD OLD VALUES AND GET NEW ONES IF ITMP > 0
      IN=1
      ITMPO=ITMP
      END IF
 
      IF(ITMP.LE.0) RETURN
 
      DO 10 K=1,NLAY
      DO 10 I=1,NROW
      DO 10 J=1,NCOL
10    IBUFF(J,I,K)=0
 
      IERR=0
      DO 20 N=1,ITMP
      NN= 4*(N-1)
      IF(IN.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,K,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,I,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,J,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,IS,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,IR,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,F,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,H,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,C,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,E,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,STOP,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,IFACE,RDUMMY,I7,IU)
      STRSV(NN+1)=K
      STRSV(NN+2)=I
      STRSV(NN+3)=J
      STRSV(NN+4)=IFACE
      ELSE
      K= STRSV(NN+1)
      I= STRSV(NN+2)
      J= STRSV(NN+3)
      IFACE= STRSV(NN+4)
      END IF
C
      IB=IBOUND(J,I,K)
      IF(IB.LE.0) THEN
      IF(IB.EQ.0) WRITE(I7,5030) J,I,K
      IF(IB.LT.0) WRITE(I7,5040) J,I,K
5030  FORMAT (' A STREAM WAS SPECIFIED FOR INACTIVE CELL (J,I,K) =',
     12(I4,','),I4)
5040  FORMAT (' A STREAM WAS SPECIFIED FOR CONSTANT HEAD CELL (J,I,K) =
     1(',I3,',',I3,',',I3,')')
      IERR=IERR+1
      GO TO 20
      END IF
C
      IF(IBUFF(J,I,K).EQ.1 .OR. IREADQ.EQ.0) GO TO 20
      IBUFF(J,I,K)=1
      CALL ADDQ (BUFF(J,I,K),QSS,QX,QY,QZ,DELR,DELC,IBOUND,IB,NCOL,NROW,
     1 NLAY,NCP1,NRP1,NLP1,J,I,K,IFACE,'STREAM',I7)
20    CONTINUE
 
C... CLEAR OUT THE REST OF THE STREAM PACKAGE DATA FOR THIS PERIOD
C
      IF(IN.EQ.1) THEN
 
      NSS=STRSV(NSTRSV-3)
      NTRIB=STRSV(NSTRSV-2)
      NDIV=STRSV(NSTRSV-1)
      ICALC=STRSV(NSTRSV)
C
      IF(ICALC.GT.0) THEN
      DO 30 L=1,ITMP
30    READ(IU,'(A)') LINE
      END IF
C
      IF(NTRIB.GT.0) THEN
      DO 40 L=1,NSS
40    READ(IU,'(A)') LINE
      END IF
C
      IF(NDIV.GT.0) THEN
      DO 50 L=1,NSS
50    READ(IU,'(A)') LINE
      END IF
 
      END IF
C
      IF (IERR.GT.0.AND.ISILNT.EQ.0) THEN
      WRITE (*,5046) IERR
5046  FORMAT(' STREAMS WERE SPECIFIED FOR ',I4,' INACTIVE OR CONSTANT HE
     1AD CELLS')
      WRITE (*,*) 'A LIST IS PROVIDED IN THE "SUMMARY.PTH"  FILE'
      END IF
 
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE WELINP (IU,QX,QY,QZ,IBOUND,NCOL,NROW,NLAY,
     1NCP1,NRP1,NLP1,QSS,DELR,DELC,I7,ISILNT,KPER,WELSV,
     2NWELSV,ITMPO,NEWPER,IREADQ)
C
      DIMENSION QX(NCP1,NROW,NLAY),QY(NCOL,NRP1,NLAY),
     1QZ(NCOL,NROW,NLP1),IBOUND(NCOL,NROW,NLAY),
     2QSS(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),WELSV(NWELSV)
      CHARACTER*80 LINE
C
C... CHECK TO SEE IF IT IS A NEW STRESS PERIOD. IF SO, READ ITMP.
      IF(NEWPER.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,ITMP,RDUMMY,I7,IU)
 
C... ITMP CANNOT BE < 0 FOR THE FIRST STRESS PERIOD
      IF(ITMP.LT.0 .AND. KPER.EQ.1) THEN
      WRITE(I7,*) 'ITMP < 0 FOR STRESS PERIOD 1. RUN STOPPED.'
      STOP
      END IF
 
      ELSE
 
C... IF NOT A NEW STRESS PERIOD, SET ITMP= -1 AND PROCEED
      ITMP= -1
      END IF
 
C... ITMP < 0 MEANS USE OLD VALUES
      IF(ITMP.LT.0) THEN
      IN=0
      ITMP=ITMPO
 
      ELSE
 
C... ITMP >= 0 MEANS DISCARD OLD VALUES AND GET NEW ONES IF ITMP > 0
      IN=1
      ITMPO=ITMP
      END IF
 
      IF(ITMP.LE.0) RETURN
 
C... GET NEW VALUES IF ITMP > 0
      IERR=0
      DO 10 N=1,ITMP
      NN= 5*(N-1)
      IF(IN.EQ.1) THEN
      READ(IU,'(A)') LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,K,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,I,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,J,RDUMMY,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,3,NDUMMY,Q,I7,IU)
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,IFACE,RDUMMY,I7,IU)
      WELSV(NN+1)=K
      WELSV(NN+2)=I
      WELSV(NN+3)=J
      WELSV(NN+4)=Q
      WELSV(NN+5)=IFACE
      ELSE
      K= WELSV(NN+1)
      I= WELSV(NN+2)
      J= WELSV(NN+3)
      Q= WELSV(NN+4)
      IFACE= WELSV(NN+5)
      END IF
 
      IB=IBOUND(J,I,K)
      IF (IB.LE.0) THEN
      IF (IB.EQ.0) WRITE (I7,5020) J,I,K
      IF (IB.LT.0) WRITE (I7,5030) J,I,K
5020  FORMAT (' A WELL WAS SPECIFIED FOR INACTIVE CELL (J,I,K) = (',I3,
     1',',I3,',',I3,')')
5030  FORMAT (' A WELL WAS SPECIFIED FOR CONSTANT HEAD CELL (J,I,K) = ('
     1,I3,',',I3,',',I3,')')
      IERR=IERR+1
      GO TO 10
      END IF
      IF(IREADQ.NE.0) THEN
      CALL ADDQ (Q,QSS,QX,QY,QZ,DELR,DELC,IBOUND,IB,NCOL,NROW,NLAY,
     1           NCP1,NRP1,NLP1,J,I,K,IFACE,'WELL',I7)
      END IF
10    CONTINUE
 
      IF (IERR.GT.0) THEN
      IF (ISILNT.EQ.0) THEN
      WRITE (*,5040) IERR
5040  FORMAT(' WELLS WERE SPECIFIED FOR ',I4,' INACTIVE OR CONSTANT HEAD
     1 CELLS')
      WRITE (*,*) 'A LIST IS PROVIDED IN THE "SUMMARY.PTH"  FILE'
      END IF
      END IF
      RETURN
5050  FORMAT(3I10,F10.0,I10)
      END