C MODPATH-PLOT Version 3.00 (V3, Release 2, 6-2000)
C Changes:
C   Fixed variable name typo of "I0" to "IO".
C Previous release: MODPATH-PLOT Version 3.00 (V3, Release 1, 9-94)
C***** SUBROUTINES *****
C     GETLAY
C     OPNFIL
C     CHOP
C     UPCASE
C     UREADI
C     EZONES
C     SCPLOT
C     XYLOC
C     CTRAN
C     FINDUN
C     ND2IJK
C     GETSTP
C     STPSIZ
C     BEEP
C     GETPS
C     GETSET
C     GETCMD
C     PAKSTR
C     COMENT
C     NUMCNV
C***********************
 
C***** SUBROUTINE *****
      SUBROUTINE GETLAY(BUFF,KSTP,KPER,PERTIM,TOTIM,TXT,NC,NR,K,NCOL,
     1            NROW,IUHED,IO,IEND,IOP)
      DIMENSION BUFF(NCOL,NROW)
      CHARACTER*(*) TXT
      CHARACTER*132 LINE
      CHARACTER*20 FMT
      CHARACTER*16 STRING,TEXT
 
      TEXT= TXT
      CALL UPCASE(TEXT)
      CALL CHOP(TEXT,LTEXT)
      IF(LTEXT.EQ.0) LTEXT=1
 
C... IUHED < 0 MEANS READ AN UNFORMATTED HEAD FILE
      IF(IUHED.LT.0) THEN
      IU= -IUHED
      READ(IU,END=10,ERR=30) KSTP,KPER,PERTIM,TOTIM,STRING,NC,NR,K
      N= -1
      IF(TEXT.NE.' ') N= INDEX(STRING,TEXT(1:LTEXT))
      IF(N.EQ.0) GO TO 20
      READ(IU) ((BUFF(J,I),J=1,NCOL),I=1,NROW)
 
C... OTHERWISE READ A FORMATTED FILE
      ELSE
      IU=IUHED
 
C... IF THIS IS A FORMATTED HEAD FILE FROM MODFLOW, READ THE HEADER
      IF(IOP.EQ.0) THEN
      READ(IU,'(A)',END=10,ERR=40) LINE
      ICOL=1
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,2,KSTP,RDUMMY,IO,IU)
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,2,KPER,RDUMMY,IO,IU)
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,3,IDUMMY,PERTIM,IO,IU)
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,3,IDUMMY,TOTIM,IO,IU)
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,1,IDUMMY,RDUMMY,IO,IU)
        IF(TEXT.NE.' ') THEN
          N= INDEX(LINE(IWFRST:IWLAST),TEXT(1:LTEXT))
          IF(N.EQ.0) GO TO 20
        END IF
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,2,NC,RDUMMY,IO,IU)
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,2,NR,RDUMMY,IO,IU)
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,2,K,RDUMMY,IO,IU)
      CALL URWORD(LINE,ICOL,IWFRST,IWLAST,1,IDUMMY,RDUMMY,IO,IU)
      FMT= LINE(IWFRST:IWLAST)
      IF(FMT.EQ.' ') FMT='(FREE)'
      IF(NC.NE.NCOL .OR. NR.NE.NROW) THEN
        WRITE(IO,*) 'INCONSISTENT DIMENSIONS IN HEAD FILE. STOP.'
        STOP
      END IF
 
C... OR, IF THIS IS JUST A TEXT FILE THAT CONTAINS AN ARRAY, FIGURE OUT
C    WHETHER IT SHOULD BE READ FREE OR WITH FORMAT. THEN SKIP DOWN TO THE
C    LINE WHERE THE ARRAY STARTS.
      ELSE
        REWIND(IU)
        IF(TEXT.EQ.' '.OR.TEXT.EQ.'(*)'.OR.TEXT.EQ.'(FREE)') THEN
          FMT= '(FREE)'
        ELSE
          FMT=TEXT
        END IF
        IF(IOP.GT.1) THEN
          DO 1 N=1,IOP-1
          READ(IU,*,END=50)
1         CONTINUE
        END IF
      END IF
 
C... NOW READ THE ARRAY FROM THE TEXT FILE
      DO 5 I=1,NROW
        IF(FMT.EQ.'(FREE)') THEN
          READ(IU,*,END=50) (BUFF(J,I),J=1,NCOL)
        ELSE
          READ(IU,FMT,END=50) (BUFF(J,I),J=1,NCOL)
        END IF
5     CONTINUE
      END IF
c
      IEND=0
      RETURN
 
C... HANDLE ERRORS AND SPECIAL RETURN CODES
 
C...  END OF FILE REACHED
10    IEND=1
      RETURN
 
C... POSSIBLY A VALID HEADER, BUT DOES NOT HAVE "HEAD" FLAG IN TEXT STRING
20    WRITE(IO,1000) TEXT(1:LTEXT)
1000  FORMAT(1X,A,' FILE DOES NOT HAVE VALID HEADER RECORD. STOP.')
      STOP
 
C... PROBLEM READING HEADER RECORD
30    WRITE(IO,1100) TEXT(1:LTEXT)
1100  FORMAT(' ERROR READING HEADER RECORD IN UNFORMATTED ',A,
     1' FILE. STOP.')
      STOP
 
40    WRITE(IO,1200) TEXT(1:LTEXT)
1200  FORMAT(' ERROR READING HEADER RECORD IN FORMATTED ',A,
     1' FILE. STOP.')
      STOP
 
50    WRITE(IO,1300) IU
1300  FORMAT(1X,'END-OF-FILE ON UNIT ',I3,'. STOP.')
      STOP
      END
 
C***** SUBROUTINE *****
      SUBROUTINE OPNFIL (IU,FNAME,NSTAT,IOUT,IBATCH,NACT)
      CHARACTER*80 FMT,FM,ACCESS
      CHARACTER*(*) FNAME
      LOGICAL*4 EX
C
C                     VARIABLES
C
C  IU = FORTRAN UNIT NUMBER OF FILE
C  FNAME = FILE NAME
C  NSTAT = STATUS OF FILE
C          1 => OLD FILE
C          2 => NEW FILE
C          3 => SCRATCH FILE (DELETED AUTOMATICALLY WHEN RUN ENDS)
C          4 => UNDETERMINED STATUS (MAY OR MAY NOT EXIST)
C                 IF IT DOES NOT EXIST, IT IS CREATED BY OPEN STATEMENT
C                 IF IT DOES EXIST, IT IS OPENED AS 'OLD' FILE
C
C  IOUT = UNIT NUMBER FOR OUTPUT FILE TO WRITE ERROR MESSAGE TO
C         IF NECESSARY
C
C  IBATCH = FLAG INDICATING IF THERE IS INTERACTIVE DIALOGUE AT
C           TERMINAL
C
C           0 => THERE IS INTERACTIVE DIALOGUE
C           1 => THERE IS NOT INTERACTIVE DIALOGUE (BATCH MODE)
C
C  NACT = VARIABLE DENOTING IF A FILE IS READ ONLY, WRITE ONLY, OR
C         READ AND WRITE.
C
C           1 => READ ONLY
C           2 => WRITE ONLY
C           3 => READ AND WRITE
C
C  "NACT" IS NOT USED IN THIS SUBROUTINE. ALL FILES ARE OPENED FOR
C  READING AND WRITING. OPENING "READ ONLY" AND "WRITE ONLY" FILES
C  IS MACHINE DEPENDENT. THE VARIABLE "NACT" IS PASSED TO THIS
C  ROUTINE TO MAKE IT EASY TO MODIFY THE OPEN STATEMENTS TO ALLOW
C  FOR READ AND WRITE ONLY FILES ON ANY GIVEN MACHINE. THE CALLS TO
C  THIS SUBROUTINE ARE CURRENTLY SET UP SO THAT ANY FILE THAT IS
C  WRITTEN TO IS GIVEN "NACT = 3" AND ANY FILE THAT IS READ FROM BUT
C  NOT WRITTEN TO IS GIVEN "NACT = 1". NO FILES ARE GIVEN "WRITE ONLY"
C  STATUS. "READ ONLY" STATUS IS USEFUL IF A NUMBER OF USERS WANT
C  TO SIMULTANEOUSLY SHARE INPUT FILES.
C
C  IF THE FILE DOES NOT CURRENTLY EXIST, A NEGATIVE UNIT NUMBER IS
C  USED AS A FLAG TO INDICATED THAT A NEW FILE SHOULD BE CREATED AS
C  AN UNFORMATTED (BINARY) FILE.
C
      IBIN=0
      IF (IU.LT.0) THEN
      IU= -IU
      IBIN=1
      END IF
C
C  CHECK TO SEE IF A FILE IS OPENED TO UNIT=IOUT SO THAT ERROR
C  MESSAGES CAN BE WRITTEN.
      INQUIRE (UNIT=IOUT,OPENED=EX)
      IO=0
      IF (EX) IO=1
C
C  OPEN AN EXISTING FILE
C
      IF (NSTAT.EQ.1) THEN
10    INQUIRE (FILE=FNAME,EXIST=EX,UNFORMATTED=FM)
C  CHECK TO SEE IF FILE EXISTS
      IF (EX) GO TO 20
      IF (IBATCH.EQ.0) THEN
      WRITE (*,*) 'THE FOLLOWING FILE DOES NOT EXIST:'
      WRITE (*,'(1X,A)') FNAME
      WRITE (*,*) 'ENTER THE NAME OF AN EXISTING FILE (<CR>=QUIT):'
      READ (*,'(A)') FNAME
      IF (FNAME.EQ.' ') STOP
      GO TO 10
      ELSE
      IF (IO.EQ.1) WRITE (IOUT,*) 'FILE DOES NOT EXIST:'
      IF (IO.EQ.1) WRITE (IOUT,'(A)') FNAME
      STOP
      END IF
20    CONTINUE
      FMT='FORMATTED'
      IF (IBIN.EQ.1.OR.FM.EQ.'YES') FMT='UNFORMATTED'
      OPEN (IU,FILE=FNAME,STATUS='OLD',FORM=FMT,IOSTAT=IERR)
      IF (IERR.GT.0) GO TO 40
      RETURN
      END IF
C
C  OPEN A NEW FILE
C
      IF (NSTAT.EQ.2) THEN
30    INQUIRE (FILE=FNAME,EXIST=EX)
      IF (EX) THEN
      IF (IBATCH.EQ.0) THEN
      WRITE (*,*) 'THE FOLLOWING FILE ALREADY EXISTS:'
      WRITE (*,'(1X,A)') FNAME
      WRITE (*,*) 'ENTER THE NAME OF A NEW FILE (<CR>=QUIT):'
      READ (*,'(A)') FNAME
      IF (FNAME.EQ.' ') STOP
      GO TO 30
      ELSE
      IF (IO.EQ.1) WRITE (IOUT,*) 'FILE ALREADY EXISTS:'
      IF (IO.EQ.1) WRITE (IOUT,'(A)') FNAME
      STOP
      END IF
      END IF
      FMT='FORMATTED'
      IF (IBIN.EQ.1) FMT='UNFORMATTED'
      OPEN (IU,FILE=FNAME,STATUS='NEW',FORM=FMT,IOSTAT=IERR)
      IF (IERR.GT.0) GO TO 40
      RETURN
      END IF
C
C  OPEN A SCRATCH FILE
C
      IF (NSTAT.EQ.3) THEN
      FMT='FORMATTED'
      IF (IBIN.EQ.1) FMT='UNFORMATTED'
      OPEN (IU,STATUS='SCRATCH',FORM=FMT,IOSTAT=IERR)
C  FOR MICROSOFT FORTRAN USE:
C      OPEN (IU,FORM=FMT,IOSTAT=IERR)
      IF (IERR.GT.0) GO TO 40
      RETURN
      END IF
C
C  OPEN A FILE OF UNKNOWN STATUS
C
      IF (NSTAT.EQ.4) THEN
      INQUIRE (FILE=FNAME,EXIST=EX,UNFORMATTED=FM)
      IF (EX) THEN
      FMT='FORMATTED'
      IF (IBIN.EQ.1.OR.FM.EQ.'YES') FMT='UNFORMATTED'
      OPEN (IU,FILE=FNAME,STATUS='OLD',FORM=FMT,IOSTAT=IERR)
      IF (IERR.GT.0) GO TO 40
      ELSE
      FMT='FORMATTED'
      IF (IBIN.EQ.1) FMT='UNFORMATTED'
      OPEN (IU,FILE=FNAME,STATUS='NEW',FORM=FMT,IOSTAT=IERR)
      IF (IERR.GT.0) GO TO 40
      END IF
      RETURN
      END IF
C
C  WRITE MESSAGE INDICATING PROBLEM OPENING FILE
C
40    IF (IBATCH.EQ.0) WRITE (*,5000) IU
      IF (IO.EQ.1 .AND. IOUT.GT.0) WRITE (IOUT,5000) IU
5000  FORMAT (' ERROR OPENING FILE TO UNIT ',I3)
      STOP
      END
 
C***** SUBROUTINE *****
      SUBROUTINE CHOP(STRING,LNG)
      CHARACTER*(*) STRING
C
      LNGSTR= LEN(STRING)
      DO 1 N=LNGSTR,1, -1
      IF(STRING(N:N).NE.' ') THEN
      LNG=N
      GO TO 5
      END IF
1     CONTINUE
      LNG=0
5     RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE UPCASE(STRING)
      CHARACTER*(*) STRING
      CHARACTER*26 LETTER
      CHARACTER*1 CLC
C
      LETTER= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
C
      IOFF= ICHAR('a') - ICHAR('A')
      LNG= LEN(STRING)
C
      DO 10 N=1,LNG
      DO 1 L=1,26
      ICLC= ICHAR(LETTER(L:L)) + IOFF
      CLC= CHAR(ICLC)
      IF(STRING(N:N).EQ.CLC) THEN
      STRING(N:N)=LETTER(L:L)
      GO TO 10
      END IF
1     CONTINUE
10    CONTINUE
C
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE UREADI(IARRAY,NDIM,IU,I7)
      DIMENSION IARRAY(NDIM)
      CHARACTER*133 LINE
C
      N1=1
5     READ(IU,'(A)') LINE
      ICOL=1
      DO 10 N=N1,NDIM
      CALL URWORD(LINE,ICOL,IWSTRT,IWLAST,2,IARRAY(N),RDUMMY,I7,IU)
      IF(LINE(IWSTRT:IWLAST).EQ.' ') THEN
      N1=N
      GO TO 5
      END IF
10    CONTINUE
C
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE EZONES (IB,ICMPCT,NCOL,NROW,NLAY,IUEP,IUIZP,NPTCL)
      DIMENSION IB(NCOL,NROW,NLAY)
      INTEGER*4 IBF,IBL
C
      IVER=0
      KOUNT=0
10    CONTINUE
      CALL READEP(IUEP,IVER,ICMPCT,IZL,JLAST,ILAST,KLAST,XLAST,YLAST,
     1  ZLLAST,T,XFRST,YFRST,ZLFRST,JFRST,IFRST,KFRST,IZF,NSFRST,
     2  IDCODE,TRLEAS,NSTEP,NCOL,NROW,IEOF)
 
C  IF IVER=0 AT THIS POINT, THERE IS SOMETHING WRONG IN THE ENDPOINT FILE
      IF(IVER.EQ.0) THEN
        WRITE(*,*) 'INVALID ENDPOINT FILE. STOP.'
        STOP
      END IF
 
C  QUIT LOOP IF AN END-OF-FILE WAS FOUND.
      IF(IEOF.EQ.1) GO TO 20
 
      KOUNT=KOUNT+1
      N= 2*KOUNT - 1
      NP1=N+1
      IBF=IB(JFRST,IFRST,KFRST)
      IBL=IB(JLAST,ILAST,KLAST)
      WRITE(IUIZP,REC=N) IBF
      WRITE(IUIZP,REC=NP1) IBL
      GO TO 10
20    CONTINUE
      NPTCL=KOUNT
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE SCPLOT (PLONG,PL,PSHORT,PS,IPAGE,XMIN,XMAX,YMIN,YMAX,
     1XL,XR,YB,YT,JUNITS,ISCTYP,PSCFAC,MAPSCA,LEGEND,XLL,XRR,YBB,YTT,
     2WINLEG)
      DIMENSION WINLEG(4)
 
C--- SET BORDER DIMENSIONS AND RESERVE SPACE FOR LEGEND IF NEEDED
      XBDR=0.05
      IF(LEGEND.EQ.0) THEN
        XLEG=0.0
      ELSE
        XLEG=0.2
      END IF
      YTBDR=0.118
      YBBDR=0.176
 
      IPAGE=1
      UNITS=12.0
      IF(JUNITS.EQ.2) UNITS=39.3701
      PL=(1.0 - 2*XBDR - XLEG)*PLONG
      PS=(1.0 - YTBDR - YBBDR)*PSHORT
      XLNG=XMAX-XMIN
      YLNG=YMAX-YMIN
        R=YLNG/XLNG
        PSPL=PS/PL
        IF(R.LE.PSPL) THEN
          YLNG=PSPL*XLNG
          SCA=XLNG*UNITS/PL
        ELSE
          XLNG=YLNG/PSPL
          SCA=XLNG*UNITS/PL
        END IF
 
      SCMAX=SCA
      MAXSC=SCMAX
      IF(ISCTYP.EQ.0 .AND. MAPSCA.GT.MAXSC) THEN
        SCA=MAPSCA
        XLNG=XLNG*SCA/SCMAX
        YLNG=YLNG*SCA/SCMAX
      END IF
 
      XPCNTR= (XMIN+XMAX)/2.0
      DENOM= 1.0 - 2.0*XBDR - XLEG
      XLL= XPCNTR - (XBDR*XLNG)/DENOM - (XLNG/2.0)
      XRR= XLL + (XLNG/DENOM)
      XL= XLL + (XBDR*XLNG/DENOM)
      XR= XL + XLNG
      IF(LEGEND.NE.0) THEN
        WINLEG(1)= XR + (0.1*XLEG*XLNG/DENOM)
        WINLEG(2)= XR
      END IF
 
      YPCNTR= (YMIN+YMAX)/2.0
      DENOM= 1.0 - YBBDR - YTBDR
      YBB= YPCNTR - (YBBDR*YLNG/DENOM) - (YLNG/2.0)
      YTT= YBB + (YLNG/DENOM)
      YB= YBB + (YBBDR*YLNG/DENOM)
      YT= YTT - (YTBDR*YLNG/DENOM)
      IF(LEGEND.NE.0) THEN
        WINLEG(3)= YB
        WINLEG(4)= YT
      END IF
 
      IF(ISCTYP.EQ.1 .AND. PSCFAC.LT.1) THEN
        XMID= (XLL+XRR)/2.0
        YMID= (YBB+YTT)/2.0
        XLL= XMID - (XMID-XLL)/PSCFAC
        XRR= XMID + (XRR-XMID)/PSCFAC
        YBB= YMID - (YMID-YBB)/PSCFAC
        YTT= YMID + (YTT-YMID)/PSCFAC
        CALL QFADN(IH1,IH2)
        H1= FLOAT(IH1)/PSCFAC
        H2= FLOAT(IH2)/PSCFAC
        NH1=H1
        NH2=H2
        CALL SFADN(NH1,NH2)
      END IF
 
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE XYLOC(NCOL,NROW,XMN,XMX,YMN,YMX,YMNR,YMXR,XLOC,YLOC)
      DIMENSION XMN(NCOL),XMX(NCOL),YMN(NROW),YMX(NROW),YMNR(NROW),
     1          YMXR(NROW),XLOC(NCOL),YLOC(NROW)
C
      DO 1 J=1,NCOL
      XLOC(J)= (XMN(J) + XMX(J))/2.0
1     CONTINUE
C
      DO 2 I=1,NROW
      II=NROW-I+1
      YMNR(II)=YMN(I)
      YMXR(II)=YMX(I)
2     CONTINUE
C
      DO 3 I=1,NROW
      YLOC(I)= (YMNR(I) + YMXR(I))/2.0
3     CONTINUE
C
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE CTRAN(NDIM,X,Y,W,V,IOPT)
      DIMENSION X(NDIM),Y(NDIM)
      DIMENSION W(4),V(4)
C
      SCAY=(W(4)-W(3))/(V(4)-V(3))
      SCAX=(W(2)-W(1))/(V(2)-V(1))
C
      DO 10 N=1,NDIM
      IF(IOPT.EQ.1) THEN
      X(N)= V(1) + (X(N)-W(1))/SCAX
      Y(N)= V(3) + (Y(N)-W(3))/SCAY
      ELSE IF(IOPT.EQ.2) THEN
      X(N)= (X(N)-V(1))*SCAX + W(1)
      Y(N)= (Y(N)-V(3))*SCAY + W(3)
      END IF
10    CONTINUE
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE FINDUN(IU)
      LOGICAL OPSTAT
C
      DO 10 N=30,99
      INQUIRE(UNIT=N,OPENED=OPSTAT)
      IF(OPSTAT) GO TO 10
      IU=N
      RETURN
10    CONTINUE
      WRITE(*,*) 'No available unit to open file. STOP.'
      STOP
      END
 
C***** SUBROUTINE *****
      SUBROUTINE ND2IJK(ND,I,J,K,NROW,NCOL)
      INTEGER*4 ND,NRC,NC4,ONE,I4,J4,K4
      NRC= NROW*NCOL
      NC4=NCOL
      ONE=1
      K4= ONE + (ND-ONE)/NRC
      I4= ONE + (ND - (K4-ONE)*NRC - ONE)/NC4
      J4= ND - (K4-ONE)*NRC - (I4-ONE)*NC4
      I=I4
      J=J4
      K=K4
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE GETSTP(KPER,KSTP,NUMTS,NPER,IU,NSTEP)
      DIMENSION NUMTS(NPER)
C
      NSTEP=0
      IF(KPER.GT.NPER) GO TO 20
      DO 10 K=1,KPER
      IF(K.EQ.KPER) THEN
      NSTP=KSTP
      ELSE
      NSTP=NUMTS(K)
      END IF
      IF(NSTP.GT.NUMTS(K)) GO TO 20
      DO 10 N=1,NSTP
      NSTEP=NSTEP+1
10    CONTINUE
      RETURN
20    WRITE(*,*)
     1'ERROR COMPUTING TIME STEP NUMBER IN ROUTINE <GETSTP>. STOP.'
      WRITE(IU,*)
     1'ERROR COMPUTING TIME STEP NUMBER IN ROUTINE <GETSTP>. STOP.'
      STOP
      END
 
C***** SUBROUTINE *****
      SUBROUTINE STPSIZ(PERLEN,KSTP,NSTP,TMULT,STPL)
C
      IF(TMULT.NE.1.) THEN
      STPL=PERLEN*(1.-TMULT)/(1.-TMULT**NSTP)
      IF (KSTP.GT.1) THEN
      DO 10 N=2,KSTP
      STPL=TMULT*STPL
10    CONTINUE
      END IF
      ELSE
      RSTP=NSTP
      STPL=PERLEN/RSTP
      END IF
C
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE BEEP
      CHARACTER*1 BELL
      BELL= CHAR(7)
      WRITE(*,'(1X,A1)') BELL
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE GETPS(PERLEN,NUMTS,TIMX,NPER,TIMREL,TBEGIN,KKPER,
     1                 KKSTP,IERR)
      DIMENSION PERLEN(NPER),NUMTS(NPER),TIMX(NPER)
C
      IERR=0
      T=TBEGIN
      IF(TIMREL.LT.T) THEN
      IERR=1
      RETURN
      END IF
      DO 10 KP=1,NPER
      NSTPS=NUMTS(KP)
      TMULT=TIMX(KP)
      PERL=PERLEN(KP)
      DO 10 KS=1,NSTPS
      CALL STPSIZ(PERL,KS,NSTPS,TMULT,DT)
      TOLD=T
      T=T+DT
      IF(TIMREL.LE.T) THEN
      KKPER=KP
      KKSTP=KS
      TIMREL= (TIMREL-TOLD)/DT
      IF(TIMREL.LT.0.0) TIMREL=0.0
      IF(TIMREL.GT.1.0) TIMREL=1.0
      RETURN
      END IF
10    CONTINUE
      IERR=2
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE GETSET(IU,IO)
      CHARACTER*30 COLNAM
      CHARACTER*81 LINE,PARAMS,CMD,WNDSTR(2),LAYOUT
      CHARACTER*1 DELIM,INLINE
      COMMON /COLNAM/ COLNAM(15)
      COMMON /COLORS/
     1 ICO(20),ICYCL(20),CTR(0:255),CTG(0:255),CTB(0:255),NCYCL,NCTDEF,
     2 MCI
      COMMON /PAT/ NLTYPE,IACPAT,ICBPAT
      COMMON /HATCH/ NFLIN1,NFLIN2,NFSTYL
      COMMON /WIND/ WNDSTR
      COMMON /GEOL/ IGEOL(100),NGEOL
      COMMON /ORIENT/ LAYOUT
      COMMON /DMARKR/ IEPTYP,EPSCAL,MKIND
C
      NFLN1=NFLIN1
      NFLN2=NFLIN2
      DELIM=  ':'
      INLINE= '@'
 
C
C--- READ COLOR CYCLE DATA.
10    READ(IU,'(A)',END=11) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 10
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'COLORCYCLE') GO TO 10
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,NCYCL,RDUMMY,IO,IU)
      DO 12 N=1,NCYCL
13    CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,ICYCL(N),RDUMMY,IO,IU)
      IF(PARAMS(IWSTRT:IWLAST).EQ.' ') THEN
      READ(IU,'(A)',END=11) PARAMS
      ICOL=1
      GO TO 13
      END IF
12    CONTINUE
      GO TO 10
11    REWIND(IU)
 
C--- READ ITEM COLOR DATA.
20    READ(IU,'(A)',END=21) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 20
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'ITEMCOLOR') GO TO 20
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,I,RDUMMY,IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,ICO(I),RDUMMY,IO,IU)
      GO TO 20
21    REWIND(IU)
 
C--- READ COLOR TABLE DATA.
30    READ(IU,'(A)',END=31) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 30
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'COLORTABLE') GO TO 30
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,I,RDUMMY,IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,3,NDUMMY,CTR(I),IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,3,NDUMMY,CTG(I),IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,3,NDUMMY,CTB(I),IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,0,NDUMMY,RDUMMY,IO,IU)
      IF(I.GT.0 .AND. I.LE.15) COLNAM(I)=PARAMS(IWSTRT:IWLAST)
      GO TO 30
31    REWIND(IU)
 
C--- READ HATCH SHADE SCALING FACTORS FOR HORIZONTAL/VERTICAL LINES AND
C    FOR DIAGONAL LINES.
50    READ(IU,'(A)',END=51) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 50
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'HATCHDENSITY') GO TO 50
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,3,NDUMMY,HVSCAL,IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,3,NDUMMY,DSCAL,IO,IU)
      X= FLOAT(NFLIN1)
      Y= X*HVSCAL
      NFLN1= IFIX(Y)
      X= FLOAT(NFLIN2)
      Y= X*DSCAL
      NFLN2= IFIX(Y)
      GO TO 50
51    REWIND(IU)
      IF(NFLN1.NE.NFLIN1) NFLIN1=NFLN1
      IF(NFLN2.NE.NFLIN2) NFLIN2=NFLN2
 
C--- READ OPTIONAL WINDOW SIZE PARAMETERS
60    READ(IU,'(A)',END=61) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 60
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'WINDOWSIZE') GO TO 60
      WNDSTR(1)= PARAMS
      GO TO 60
61    REWIND(IU)
 
C--- READ OPTIONAL WINDOW TITLE
70    READ(IU,'(A)',END=71) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 70
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'WINDOWTITLE') GO TO 70
      WNDSTR(2)= PARAMS
      GO TO 70
71    REWIND(IU)
 
C--- READ LINE TYPE
80    READ(IU,'(A)',END=81) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 80
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'LINETYPE') GO TO 80
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,NLTYPE,RDUMMY,IO,IU)
      GO TO 80
81    REWIND(IU)
 
C--- READ INACTIVE CELL SHADE PATTERN
90    READ(IU,'(A)',END=91) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 90
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'INACTIVECELLPATTERN') GO TO 90
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,IDUMMY,RDUMMY,IO,IU)
      IF(IDUMMY.GE.1 .AND. IDUMMY.LE.6) IACPAT=IDUMMY
      GO TO 90
91    REWIND(IU)
 
C--- READ GEOLOGIC ZONE SHADE PATTERN
100   READ(IU,'(A)',END=101) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 100
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'GRIDUNIT') GO TO 100
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,N1,RDUMMY,IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,N2,RDUMMY,IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,N3,RDUMMY,IO,IU)
      IGEOL(2*N1-1)=N2
      IGEOL(2*N1)=N3
      GO TO 100
101   CONTINUE
 
      REWIND(IU)
110   READ(IU,'(A)',END=111) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 110
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'LAYOUT') GO TO 110
      ICOL=1
      LAYOUT=PARAMS
      GO TO 110
111   CONTINUE
 
      REWIND(IU)
120   READ(IU,'(A)',END=121) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 120
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'CONFININGBEDPATTERN') GO TO 120
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,IDUMMY,RDUMMY,IO,IU)
      IF(IDUMMY.GE.1 .AND. IDUMMY.LE.6) ICBPAT=IDUMMY
      GO TO 120
121   REWIND(IU)
 
      REWIND(IU)
130   READ(IU,'(A)',END=131) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 130
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'DATAMARKER') GO TO 130
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,IEPTYP,RDUMMY,IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,3,IDUMMY,EPSCAL,IO,IU)
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,MKIND,RDUMMY,IO,IU)
      GO TO 130
131   CONTINUE
 
      REWIND(IU)
140   READ(IU,'(A)',END=141) LINE
      CALL COMENT(LINE,INLINE,ISTAT)
      IF(ISTAT.NE.0) GO TO 140
      CALL GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      IF(CMD(1:LCMD).NE.'COLORMENUITEMS') GO TO 140
      ICOL=1
      CALL URWORD(PARAMS,ICOL,IWSTRT,IWLAST,2,IDUMMY,RDUMMY,IO,IU)
      IF(IDUMMY.GT.0 .AND. IDUMMY.LE.15) MCI=IDUMMY
      GO TO 140
141   CONTINUE
      REWIND(IU)
 
 
      RETURN
 
C
      END
 
C***** SUBROUTINE *****
      SUBROUTINE GETCMD(LINE,DELIM,CMD,PARAMS,LCMD)
      CHARACTER*(*) LINE,CMD,PARAMS,DELIM
      PARAMS= ' '
      LENLIN= LEN(LINE)
      LM1=LENLIN-1
      NDELIM= INDEX(LINE,DELIM)
      IF(NDELIM.LE.1 .OR. NDELIM.GE.LM1) THEN
      CMD= ' '
      LCMD=1
      RETURN
      END IF
      CALL PAKSTR(LINE,CMD,NDELIM-1,LCMD,1)
      PARAMS= LINE(NDELIM+1:LENLIN)
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE PAKSTR(STR,PSTR,N,LTPSTR,ICASE)
      CHARACTER*(*) STR,PSTR
      PSTR= ' '
      LPSTR=LEN(PSTR)
      LSTR=LEN(STR)
      NN=N
      IF(N.GT.LSTR) NN=LSTR
      KOUNT=0
      DO 1 K=1,NN
      IF(STR(K:K).NE.' ') THEN
      KOUNT=KOUNT+1
      IF(KOUNT.GT.LPSTR) GO TO 2
      PSTR(KOUNT:KOUNT)= STR(K:K)
      END IF
1     CONTINUE
2     CONTINUE
      IF(ICASE.EQ.1) CALL UPCASE(PSTR)
      CALL CHOP(PSTR,LTPSTR)
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE COMENT(LINE,INLINE,ISTAT)
      CHARACTER*(*) LINE,INLINE
C
      ISTAT=0
C
      IF(LINE(1:1).EQ.INLINE) THEN
        ISTAT=1
        RETURN
      END IF
C
      N= INDEX(LINE,INLINE)
        IF(N.GT.0) THEN
        LINE= LINE(1:N-1)
      END IF
C
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE NUMCNV(Z,NDEC,STRING,NCHAR)
C
      CHARACTER*20 STRING
      CHARACTER*20 BUF
      CHARACTER*7 FMT
      CHARACTER*10 DEC
      DATA FMT/'(F20.X)'/
      DATA DEC/'0123456789'/
C
      ND=NDEC+1
      IF(ND.GT.10) ND=10
      IF(ND.LT.1) ND=1
      FMT(6:6)=DEC(ND:ND)
      WRITE(BUF,FMT) Z
C
      DO 10 ISTART=1,20
      IF(BUF(ISTART:ISTART).NE.' ') GO TO 20
10    CONTINUE
C
20    ISTOP=20
      IF(NDEC.LT.0) ISTOP=19
      NCHAR=ISTOP-ISTART+1
      STRING(1:NCHAR)=BUF(ISTART:ISTOP)
      RETURN
      END