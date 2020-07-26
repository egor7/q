chk:{
 / x: dir
 f:{`/:'x,'d@&(d:!x)like"[0-9]*"};
 /         ---subdirs matched---
 /      ----`parent`subdirs-----
 /  ----` sv ' (for each) ...--- (concatenation)
 d@:>.:'$last'`\:'d:$[`par.txt in!x; ,/f'-1!'`$0:`/:x,`par.txt; f x]
 {[e;u;d]
  / e:
  / u:
  / d:
   u[i] {.[x;(y;`);:;?[z;();0b;()]]}[d]' e i:&~u in!d
 } [d[(+u in/:t)?\:1b] (0#.)'u,'`; u:?,/t:!:'d]'d
}


.Q.chk


Восстанавливает отсутствующие таблицы в партициях HDB.
Для каждой таблицы в качестве опорной выбирает схему
из наиболее поздней партиции, где присутствует таблица.


Подготовим вспомогательные функци.


== Создать таблицу в папке по ее схеме
f1:{
 / Create table(y) in directory(x) with schema(z)
 / x: directory
 / y: table
 / z: schema
 .[x;(y;`);:;?[z;();0b;()]] }

  / Example
  f1[`:hdb/2020.01.01; `t1; ([] c0:`float$())]
  hdb
  └── 2020.01.01
      └── t1
          ├── .d
          └── c0

  / Description
  / .[x;(y;`);:;?[z;();0b;()]]
  Вызываем replace-items-at-depth .[], ее аргументы:
   - x file-symbol, ссылка на директорию
   - (y;`) список ключей (поддиректорий), оканчивающийся
      либо символом, например (enlist y), тогда таблица запишется в файл
       `:hdb/2020.01.01/`t1
      либо пустым символом`, как здесь, тогда таблица запишется в
       `:hdb/2020.01.01/`t1/ как splayed - каждый столбец в свой файл
   - : replace
   - ?[z;();0b;()] функциональная форма select from z


== Создать отсутствующие таблицы в папке, зная их полный список и схемы
f2:{[e;u;d]
 / Create non-existent tables in directory(d) by their names(u) and schemas(e)
 / e: empty table list(schemas)
 / u: unique table list
 / d: dir(partition)
 u[i] f1[d]' e i:&~u in!d }

  / Example
  f1[`:hdb/2020.01.01; `t1; ([] c0:`float$())]
  f2[(([]c1:`short$()); ([]c2:`int$()); ([]c3:`long$())); `t1`t2`t3; `:hdb/2020.01.01]
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

  / Description
  / u[i] f1[d]' e i:&~u in!d


e:(([] c1:`short$());([] c2:`int$());([] c3:`long$()))
u:`t1`t2`t3
d:`:hdb/2020.01.01


  !d