# Алгоритм замещения страниц (кэш, eviction algorithm) LRU

Данный алгоритм основан на модуле [Cache::LRU](https://metacpan.org/pod/release/KAZUHO/Cache-LRU-0.04/lib/Cache/LRU.pm), 
но реализован с помощью модуля [List::DoubleLinked](https://metacpan.org/pod/List::DoubleLinked) вместо массивов. 

В рамках данной задачи был доработан класс List::DoubleLinked, а именно 

- добавлен метод splice в класс List::DoubleLinked
- добавлен метод set в класс List::DoubleLinked::Iterator
- метод size теперь возвращает размер списка за константное время O(1)

Преимущества данного кода

- простота реализации

Недостатки:

- низкая производительность, т.к. для доступа к узлам используется класс итераторов. 

TODO:

- [ ] Реализовать быстрый алгоритм с помощью CircularBuffer из https://github.com/grinya007/2q

    - [ ] использовать циклический список
    - [ ] использовать предварительное создание списка размером $size

- [ ] Реализовать быстрый алгоритм на C и C++ с использованием XS и Panda::XS

Проверка эффективности алгоритма:
```
git clone https://github.com/TheAthlete/Cache-LRU-ListDoubleLinked.git
zcat etc/ids.gz | perl bin/lru_example.pl
```
при задании максимального размера (size) равного 2000, получаются следующее:
```
worked out 1000000 keys
        hit rate:       64.762 %
        memory:         3.434 Mb
        time:           18.129 s
```
