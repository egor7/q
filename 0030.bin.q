1 3 5 bin 4 6 10
k)&/j:-1<i:([]a:1 3 5 7) bin ([]a:2 2 8 0)
([]a:1 3 5 7) bin
([]a:2 2 8 0)
/    0 0 3 -1
q).Q.ajf0
{[f;g;x;y;z]
 / x:symbols set, list
 / y:target table we apply function to
 / z:what we use to create application function, non-keyed
 $[&/j:-1<i:(x#z)bin x#y;
  y,'(x_z i);
  +.[+.Q.ff[y;x_z]; (!+x_z;j); :; .+x_z i j:&j]
  ]
 }
k)&j
