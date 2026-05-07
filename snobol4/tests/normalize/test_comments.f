C     test: comment lines (C or * in col 1) are skipped
* And star-style comments are also skipped
      INTEGER I
C     comment between statements
      I = 42
* another star comment
      END
