      MODULE MPDATA
        TYPE CELLDATA
          REAL ::VX1,VX2,VY1,VY2,VZ1,VZ2,VZCB
          REAL ::DX,DY,BOTCB,BOT,TOP,XMIN,YMIN
          REAL ::QX1,QX2,QY1,QY2,QZ1,QZ2
          REAL ::QSINK,QSOURCE,QSTO,HEAD
          REAL ::POR,PORCB,RFAC,RFACCB
          INTEGER ::ACTIVE,ZONE,LAYCBD,LAYTYP
        END TYPE CELLDATA
        TYPE CELL
          INTEGER ::GRID,I,J,K
        END TYPE CELL
        TYPE CELLBLOCK
          INTEGER ::GRID,IMIN,JMIN,KMIN,IMAX,JMAX,KMAX
        END TYPE CELLBLOCK
        TYPE CELLBUDGET
          REAL ::QFACEIN,QFACEOUT,QFACENET,QRESIDUAL,QAVE,BALANCE
          INTEGER, DIMENSION(6) ::FACEDIR
        END TYPE CELLBUDGET
        TYPE HEADEREP
          CHARACTER (LEN=80) ::LABEL
          INTEGER ::TRACKDIR,TOTALCOUNT,RELEASECOUNT,MAXID
          INTEGER, DIMENSION(0:5) ::STATUSCOUNT
          REAL ::REFTIME
        END TYPE HEADEREP
        TYPE HEADERPL
          CHARACTER (LEN=80) ::LABEL
          INTEGER ::TRACKDIR
          REAL ::REFTIME     
        END TYPE HEADERPL
        TYPE HEADERTS
          CHARACTER (LEN=80) ::LABEL
          INTEGER ::TRACKDIR
          REAL ::REFTIME
        END TYPE HEADERTS
        
        INTEGER, SAVE ::DEFAULTREALKIND,DEFAULTREALPRECISION
        INTEGER, SAVE ::NTSTEPS,NPARTICLES,ITRACKDIR
        INTEGER, SAVE ::ISIMTYPE,ISTOPT,NGRIDS,NCELLBUD,IBDOPT,IADVOBS
        INTEGER, SAVE ::INUNIT,IOLIST,NTPTS,IOPART,IOEPT,IOTRACE,IOLOG
        INTEGER, SAVE ::IUMPBAS,IUDIS,IUHEAD,IUBUDGET,INMPSIM,IOBUDCHK
        INTEGER, SAVE ::ISINK,ISOURCE,IOAOBS
        INTEGER, SAVE ::ISTOPZONE,ISTOPZONE2
        INTEGER, SAVE ::IDTRACE,ITRACESEG
        REAL,    SAVE ::STOPTIME,SIMLENGTH,REFTIME
        INTEGER, SAVE, POINTER, DIMENSION(:) ::NTPER
        INTEGER, SAVE, POINTER, DIMENSION(:) ::NTSTP
        INTEGER, SAVE, POINTER, DIMENSION(:) ::NTOFF
        REAL,    SAVE, POINTER, DIMENSION(:) ::SIMTIME
        REAL,    SAVE, POINTER, DIMENSION(:) ::TIMEPTS
        INTEGER, SAVE, DIMENSION(0:100) ::ZONETOTALS
        TYPE(CELL), SAVE, POINTER, DIMENSION(:) ::BUDGETCELLS
        CHARACTER (LEN=200) ::FENDPT,FPLINE,FTSERS,FADVOB
      END MODULE