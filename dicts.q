/https://qriouskdb.wordpress.com/2019/01/01/step-dictionaries/
d:(10*til 5)!0 1 2 3 4i
d 10
d 35 /0Ni
d 50 /0Ni
d -10 /0Ni
s:`s#(10*til 5)!0 1 2 3 4i
d~s
attr'[(d;s)]
attr each (d;s)
s 35 /3i
s 50 /4i
s -10 /0Ni
