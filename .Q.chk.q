
.Q.en
{[x;d;t;s]
 if[#c@:&{ $[11h=@*x; &/11h=@:'x; 11h=@x]}'t  c:!+t;
    (`/:d,s)??,/?:'{$[0h=@x;,/x;x]}'t c];
 @[t;c;{$[0h=@z;(-1_+\0,#:'z)_x[y;,/z];x[y;z]]}[x;s]]
}[;;;`sym][?]


@'[("aa";"a";"bbb");0;upper]
("aa";"a";"bbb")@'[0;upper]

{x+y+z}'[1 2 3;10 20 30;100 200 300]


chk:{
  / ==============================================================
  / Восстановить отсутствующие таблицы во ВСЕХ партициях HDB.
  / Для каждой таблицы в качестве опорной выбирает схему
  / из наиболее поздней партиции, где присутствует таблица.
  / ==============================================================
  /   x: `:hdb
  / ret: `:hdb/par_i
  / ==============================================================
  / chk:{f:{`/:'x,'d@&(d:!x)like"[0-9]*"}; d@:>.:'$last'`\:'d:$[`par.txt in!x;,/f'-1!'`$0:`/:x,`par.txt;f x]
  /  {[e;u;d]u[i]{.[x;(y;`);:;?[z;();0b;()]]}[d]'e i:&~u in!d}[d[(+u in/:t)?\:1b](0#.)'u,'`;u:?,/t:!:'d]'d}
  / ==============================================================
  f:{
    / ------------------------------------------------------------
    / Получить список всех партиций(file-symbol) из hdb
    / Get file-symbol list of all partitions in hdb(x)
    / ------------------------------------------------------------
    /   x: hdb
    / ret: file-symbol list of all partitions in hdb
    / ------------------------------------------------------------
    /           d:!x               / Получить ключи объекта(hdb) - список папок(партиций hdb), сохранить в d
    /          (d:!x)like"[0-9]*"  / Партиции бывают типов (day/month/year/long) - поэтому папки должны содержать цифру
    /       d@&(d:!x)like"[0-9]*"  / Взять &(where) от бинарного списка и взять @(index) значения d от него
    /                              / Итак, здесь находятся партиции
    /    x,'d@&(d:!x)like"[0-9]*"  / Добавить "," к каждой '(each) партиции папку x в которой она находится
    /`/:'x,'d@&(d:!x)like"[0-9]*"  / Склеить каждый такой список - превратить с помощью sv({x/:y}) в валидный путь
    `/:'x,'d@&(d:!x)like"[0-9]*" };


  / --------------------------------------------------------------
  / Обработать случай Segmented tables, когда ссылки на сегменты с партицями хранятся в par.txt
  / --------------------------------------------------------------
  / d: dirs (partitions)
  / --------------------------------------------------------------
  /d:$[`par.txt in!x;                                 / Если среди ключей !x(`:hdb) находится par.txt
  /d:$[`par.txt in!x;             `/:x,`par.txt       / Получить с помощью sv({x/:y}) валидный путь до par.txt
  /d:$[`par.txt in!x;           0:`/:x,`par.txt       / Прочитать par.txt - получить из него строковый список сегментов
  /d:$[`par.txt in!x;         `$0:`/:x,`par.txt       / Превратить строковый список партиций в символьный
  /d:$[`par.txt in!x;     -1!'`$0:`/:x,`par.txt       / С помощью -1!(hsym) превратить каждый '(each) символ в file-сивмол
  /d:$[`par.txt in!x;   f'-1!'`$0:`/:x,`par.txt       / С помощью f начитать из каждого '(each) сегмента список партиций
  /d:$[`par.txt in!x; ,/f'-1!'`$0:`/:x,`par.txt       / Flatten, убрать уровень вложенности возникший из-за сегментов
  /d:$[`par.txt in!x; ,/f'-1!'`$0:`/:x,`par.txt; f x] / Либо просто с помощью f начитать список партиций из hdb
  d:$[`par.txt in!x; ,/f'-1!'`$0:`/:x,`par.txt; f x];


  / --------------------------------------------------------------
  / Упорядочить список партиций d от самой новой до самой старой
  / --------------------------------------------------------------
  / d: dirs (partitions)
  / --------------------------------------------------------------
  /             `\:'d  / Превратить каждый путь до партиции в список symbol'ов
  /        last'`\:'d  / Взять последние символы (названия партиций)
  /       $last'`\:'d  / Превратить их в строки
  /    .:'$last'`\:'d  / Взять значение get (.:) от каждой, чтобы можно было сравнивать
  /   >.:'$last'`\:'d  / Упорядочить - упорядочивающие индексы, от самой новой партиции до старой
  /d@:>.:'$last'`\:'d  / Amend in place, взять d от индексов и записать обратно в d
  d@:>.:'$last'`\:'d;


  f2:{[e;u;d]
    / ------------------------------------------------------------
    / Создать отсутствующие таблицы в папке, зная их полный список и схемы
    / Create non-existent tables in directory(d) by their names(u) and schemas(e)
    / ------------------------------------------------------------
    /   e: empty table list(schemas)
    /   u: unique table list
    /   d: dir(partition)
    / ret: d
    / ------------------------------------------------------------
    f1:{
      / ----------------------------------------------------------
      / Создать таблицу в папке по ее схеме
      / Create table(y) in directory(x) with schema(z)
      / ----------------------------------------------------------
      /   x: directory
      /   y: table
      /   z: schema
      / ret: x
      / ----------------------------------------------------------
      /            ?[z;();0b;()]     / функциональная форма select from z (на случай когда нет данных, 0# не отрежет и нужно слектить)
      /.[ ;     ;:;?[z;();0b;()]]    / replace items at depth
      /.[x;     ;:;?[z;();0b;()]]    / x file-symbol, ссылка на директорию
      /.[x;(y;`);:;?[z;();0b;()]]    / (y;`) список ключей (поддиректорий), оканчивающийся
      /                              / либо символом, например (enlist y), тогда таблица запишется в файл
      /                              /   `:hdb/2020.01.01/`t1
      /                              / либо пустым символом`, как здесь, тогда таблица запишется в
      /                              /   `:hdb/2020.01.01/`t1/ как splayed - каждый столбец в свой файл
      .[x;(y;`);:;?[z;();0b;()]] };
    /                     !d       / Получить ключи объекта, в данном случае подпапки (splayed-таблицы) партиции
    /                ~u in!d       / Получить бинарный список (длины u) наличия требуемых таблиц u
    /             i:&~u in!d       / Взять where от него, сохранить в i: индексы таблиц в u, которые надо создать
    /           e i:&~u in!d       / Индексы схем e, соответствующие таблицам u, которые надо создать
    /u[i] f1[d]'e i:&~u in!d       / С помощью adverb each ' превратить проекцию(частично-примененную функцию) f1[d;;]
    /                              / в функцию, которая применится ко всем [u[i];e[i]] - второй и третий аргументы f1
    u[i] f1[d]'e i:&~u in!d };


  / --------------------------------------------------------------
  / Получить уникальный список таблиц из ВСЕХ партиций и воссоздать их во всех партициях
  / --------------------------------------------------------------
  /                                         t:!:'d    / сохранить в t список таблиц в каждой партиции (взять ключ !:)
  /                                       ,/t:!:'d    / flatten, убрать вложенность
  /                                    u:?,/t:!:'d    / уникальный набор таблиц во всех партициях
  /         u in/:t                                   / узнать по каждой партиции о вхождении в нее таблиц из u
  /       (+u in/:t)?\:1b                             / узнать максимальный номер партиции, в которую входит каждая u
  /     d[(+u in/:t)?\:1b]                            / партиции, соответствующие таблицам u, из которых брать схемы таблиц
  /     d[(+u in/:t)?\:1b]    . 'u,'`                 / данные каждой u таблицы (get или .[d_i;u_i`])
  /     d[(+u in/:t)?\:1b] (0#.)'u,'`                 / схемы данных (0# - отрезать все данные)
  / f2 [d[(+u in/:t)?\:1b] (0#.)'u,'`; u:?,/t:!:'d]'d / f2[схемы всех u; таблицы u] для каждой (') партиции d
  f2 [d[(+u in/:t)?\:1b] (0#.)'u,'`; u:?,/t:!:'d]'d }



/
/ Experiments
/
f1[`:hdb/2020.01.01; `t1; ([] c0:`float$())]
f2[(([]c1:`short$()); ([]c2:`int$()); ([]c3:`long$())); `t1`t2`t3; `:hdb/2020.01.01]
$ tree hdb
hdb             ->  hdb
└── 2020.01.01      └── 2020.01.01
    └── t1              ├── t1
        ├── .d          │   ├── .d
        └── c0          │   └── c0
                        ├── t2
                        │   ├── .d
                        │   └── c2
                        └── t3
                            ├── .d
                            └── c3

.[`:hdb/2020.01.01;`t1`;:;([] c1:1 2 3h)]    / `:hdb/2020.01.01/t1/ set ([] c1:1 2 3h)
.[`:hdb/2020.01.02;`t2`;:;([] c2:1 2 3i)]    / `:hdb/2020.01.02/t2/ set ([] c2:4 5 6i)
.[`:hdb/2020.01.03;`t3`;:;([] c3:`long$())]  / `:hdb/2020.01.03/t3/ set ([] c3:`long$())

0#.[`:hdb/2020.01.01;`t1`]  / +(,`c1)!,`short$()          
0#.[`:hdb/2020.01.02;`t2`]  / +(,`c2)!,`int$()            
0#.[`:hdb/2020.01.03;`t3`]  / +(,`c3)!`:hdb/2020.01.03/t3/

chk `:hdb
$ tree hdb
hdb             ->  hdb           
├── 2020.01.01      ├── 2020.01.01
│   └── t1          │   ├── t1    
│       └── c1      │   │   └── c1
├── 2020.01.02      │   ├── t2    
│   └── t2          │   │   └── c2
│       └── c2      │   └── t3    
└── 2020.01.03      │       └── c3
    └── t3          ├── 2020.01.02
        └── c3      │   ├── t1    
                    │   │   └── c1
                    │   ├── t2    
                    │   │   └── c2
                    │   └── t3    
                    │       └── c3
                    └── 2020.01.03
                        ├── t1    
                        │   └── c1
                        ├── t2    
                        │   └── c2
                        └── t3    
                            └── c3
