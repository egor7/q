// http://beyondloom.com/blog/strings.html

/5 - Musical Chars
k){|/y~/:(#x){1_x,x 0}\x}["abcde";"deabc"]
k){|/y~/:{1_x,x 0}\x}["abcde";"deabc"]
k){|/y~/:(1!)\x}["abcde";"deabc"] /not work in k4

/6 - Size Matters
k){<x!#:'x}("books";"apple";"peanut";"aardvark";"melon";"pie")
k){x@<#:'x}("books";"apple";"peanut";"aardvark";"melon";"pie") /better

/7 - Popularity Contest
k){*>#:'=x}"abdbbac"

/8 - esreveR A ecnetneS
k){" "/:|" "\:|x} "a few words in a sentence"
k){1_,/|:'(0,1+&" "=x)_x," "} "a few words in a sentence"
k){1_,/|:'(&" "=" ",x)_x," "} "a few words in a sentence"

/9 - Compression Session
k){x@&y}["embiggener";0 0 1 1 1 1 0 0 1 1]

/10 - Expansion Mansion
k){("_",x)@y*+\y}["bigger";0 0 1 1 1 1 0 0 1 1]

/11 - C_ns_n_nts
k){-1_,/(-1_'(&|/"aeiouyAEIOUY"=\:"a",x)_x," "),'"_"} "Several normal words"
k){-1_,/{(-1_x),"_"}'(0,1+&x in "aeiouyAEIOUY") _ x,"a"} "Several normal words"
k){{(x;"_")x in "aeiouyAEIOUY"}'x} "Several normal words"

/12 - Cnsnnts Rdx
k){x@&{~x in "aeiouyAEIOUY"}'x} "Several normal words"
k){x@&~x in "aeiouyAEIOUY"} "Several normal words"

/13 - title redacted
k){1_,/" ",'{(x;(#:y)#"X")x~y}[;y]'    -1_'(&" "=" ",x)_x," "}["one fish two fish";"fish"]
k){{x," ",y}/(+(t;(#:'t)#'"X"))@'y~/:t:-1_'(&" "=" ",x)_x," "}["one fish two fish";"fish"]

/14 - It’s More Fun to Permute
k)(1 0#()){,/ {{,/|(0;1)_x}\x,y}\: [x; y] }/"abc"
k)(1 0#()){,/ {{,/|(0;1)_x}\x,y}'  [x; y] }/"abc"
k)(1 0#()){,/ {{,/|(0;1)_x}\x  }'  (x,'y) }/"abc"
k)(1 0#()){,/  {,/|(0;1)_x}\    '   x,'y }/"abc"
k)(1 0#()){,/  (,/|(0;1)_) \    '   x,'y }/"abc"
  (1 0#()){raze(1 rotate)scan   '   x,'y }/"abc"
k)(1 0#()){,/(,/|(0;1)_)\'x,'y}/"abc" / shortest
k){:[#x;,/x,''_f'x _dv/:x;,x]} / recursive
k){x@?<:'+s \:!_ s^s:#x}"abc" / non-recursive
