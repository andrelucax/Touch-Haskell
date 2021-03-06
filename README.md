# Haskell Touch

This program was made to learn more about [Haskell](https://www.haskell.org/) and functional program.

This is a implementation of [touch](https://github.com/wertarbyte/coreutils/blob/master/src/touch.c) using [Haskell](https://www.haskell.org/).

# Notes

- This program does not have ```-d``` (```--date=STRING```) neighter ```-h``` (```--no-dereference```) flags.

- The ```-t``` flag was simplified (all elements are required).

- Concatenated flags are not allowed (instead of ```-amc``` use ```-a -m -c```).

# How to run

- Install Haskell - [tutorial](https://www.haskell.org/downloads/linux/)

- Compiling
```
$ ghc touch.hs -o touch
```

- Running (run ```$ ./mytouch --help``` for more information)
```
$ ./touch [OPTION]... FILE...
```


# Trabalho Individual - Paradigmas de Programação - 2020/1

**André Lucas de Sousa Pinto - 17/0068251**

## Sobre o Trabalho

O trabalho consistia em implementar o [touch](https://github.com/wertarbyte/coreutils/blob/master/src/touch.c) em um paradigma de programação diferente, o funcional, utilizando a linguagem [Haskell](https://www.haskell.org/).

# Notes

- O programa não apresenta as flags ```-d``` (```--date=STRING```) e ```-h``` (```--no-dereference```).

- A flag ```-t``` foi simplificada de modo a exigir todos os elementos.

- Flags concatenadas não são permitidas (invés de usar ```-amc``` use ```-a -m -c```).

## Como Rodar

- Instale o Haskell - [tutorial](https://www.haskell.org/downloads/linux/)

- Compile
```
$ ghc mytouch.hs -o mytouch
```

- Rode (execute ```$ ./mytouch --help``` para mais informações)
```
$ ./touch [OPTION]... FILE...
```
