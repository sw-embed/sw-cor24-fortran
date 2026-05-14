Ship the three classic-progression demos that build on m1-m9:
factorial, fibonacci, fizzbuzz.

Demos to land:

  examples/factorial.f  -> "120"           (5!)
  examples/fibonacci.f  -> "89"            (fib(11), iterative)
  examples/fizzbuzz.f   -> "1, 2, Fizz, 4, Buzz, Fizz, 7, 8,
                            Fizz, Buzz, 11, Fizz, 13, 14,
                            FizzBuzz" for I = 1..15

All three exercise features already shipped (m6 binary expr,
m7 GOTO+IF-GOTO, m8 DO/CONTINUE, m9 array support is not used
by these). Factorial and fibonacci are straightforward DO loops
with arithmetic. fizzbuzz is more involved: COR24 has no native
div/mod, so I'll use counter-reset increments (M3 counts up to 3
then resets; M5 counts up to 5 then resets) rather than modulo
arithmetic.

For fizzbuzz the control flow is:
  for I in 1..15:
    M3 += 1
    M5 += 1
    if M3 == 3 and M5 == 5: print "FizzBuzz"; reset both; continue
    if M3 == 3: print "Fizz"; reset M3; continue
    if M5 == 5: print "Buzz"; reset M5; continue
    print I

Expressed with single-target arithmetic IF (`IF (expr) GOTO L`
branches when expr != 0):
  IF (M3 - 3) GOTO N1  ; skip Fizz when M3 != 3
  ...

Steps:
1. add-three-classic-demos -- author examples/factorial.f,
   examples/fibonacci.f, examples/fizzbuzz.f. Verify each
   end-to-end. No emitter changes required.
2. dgmark-and-pr.
