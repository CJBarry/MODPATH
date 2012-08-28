      MODULE PARTICLEDATA
      INTEGER, SAVE ::NPGROUPS
      
      TYPE PARTICLE
        INTEGER ::GROUP,INDEX,ID,STATUS,CELLCOUNT,LINENUM
        INTEGER ::GRID,I,J,K,FACE
        INTEGER ::GRIDB,IB,JB,KB,FACEB
        REAL ::XL,YL,ZL,TIME
        REAL ::XLB,YLB,ZLB,TIMEB
        CHARACTER (LEN=40) ::LABEL
        REAL, DIMENSION(:), ALLOCATABLE ::EXITVEL
      END TYPE PARTICLE
      
      TYPE PARTICLEGROUP
        CHARACTER (LEN=16) ::NAME
        INTEGER ::COUNT,GROUP
        TYPE(PARTICLE), DIMENSION(:), ALLOCATABLE ::PARTICLES
      END TYPE PARTICLEGROUP
      
      TYPE(PARTICLEGROUP),SAVE,DIMENSION(:),ALLOCATABLE,TARGET ::PGROUPS
      
      END MODULE