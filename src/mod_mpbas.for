      MODULE MPBAS
        INTEGER, SAVE, POINTER  ::MSUM
        INTEGER, SAVE, POINTER  ::MAXCBF
        INTEGER, SAVE, POINTER  ::ISCHILD
        INTEGER, SAVE, POINTER  ::NPRBEG,NPREND
        INTEGER, SAVE, POINTER  ::NPCBEG,NPCEND
        INTEGER, SAVE, POINTER  ::NPLBEG,NPLEND
        INTEGER, SAVE, POINTER  ::NCPP
        INTEGER, SAVE, POINTER  ::IRCHTOP,IEVTTOP
        REAL,    SAVE, POINTER  ::DELT,PERTIM,TOTIM,HNOFLO,HDRY
        INTEGER, SAVE, POINTER, DIMENSION(:) ::NCPPL
      TYPE MPBASTYPE
        INTEGER, POINTER  ::MSUM
        INTEGER, POINTER  ::MAXCBF
        INTEGER, POINTER  ::ISCHILD
        INTEGER, POINTER  ::NPRBEG,NPREND
        INTEGER, POINTER  ::NPCBEG,NPCEND
        INTEGER, POINTER  ::NPLBEG,NPLEND
        INTEGER, POINTER  ::NCPP
        INTEGER, POINTER  ::IRCHTOP,IEVTTOP
        REAL,    POINTER  ::DELT,PERTIM,TOTIM,HNOFLO,HDRY
        INTEGER, DIMENSION(:), POINTER ::NCPPL
      END TYPE
      TYPE(MPBASTYPE), SAVE  ::MPBASDAT(10)
      END MODULE MPBAS
      
