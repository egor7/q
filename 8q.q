/q solution
f:{raze {(x,) each (til 8) except {x,(x-f),x+f:reverse 1+til count x} x} each x}
\ts:10 7 f/til 8 /248 100128
q8:7 f/til 8
count q8 /92
first q8 /0 4 7 5 2 6 1 3
-1 (ssr[;enlist"?";{" ",x}] ".Q" (til 8)=) each q8 0;

/k solution
f:{,/{(x,)'(!8)@&~(!8)in{x,(x-f),x+f:|1+!#x}x}'x}
\ts:10 7 f/!8 /144 100112
#7 f/!8 /92
*7 f/!8 /0 4 7 5 2 6 1 3

/k solution N
#{(x-1){,/{(x,)'(!y)@&~(!y)in{x,(x-f),x+f:|1+!#x}x}[;y]'x}[;x]/!x}8


/?qsql solution

\
/
       2                          6            3
   . . . . . . . .    . . . . . . . .    . . . . . . . .
   . . . . . . . .    . . . . . . . .    . . . . . . . .
   . . . . . . . .    . . . . . . . .    . . . . . . . .
   . . . . . . . .    . . . . . . . .    . . . . . . . .
   . . . . . . . .    . . . . . . . .    . . . . . . . .
   . . . . . . . .    . . . . . . . .  2 \ . | Q / \ | /
   . . . . . . . .  1 . \ | / . . Q .    . \ | / . . Q .
 0 . . Q . . . . .    . . Q . . . . .    . . Q . . . . .

   2 -> 2,2-(3),2+(3)
   6 -> 6,6-(2),6+(2)
   3 -> 3,3-(1),3+(1)

   2 6 3 => (2 6 3;
             2 6 3 + 3 2 1;
             2 6 3 - 3 2 1)

   {x,(x-f),x+f:reverse 1+til count x}