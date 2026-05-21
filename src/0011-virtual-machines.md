# Maquinas virtuales

Úna máquina virtual es una partición de un equipo físico (host) que se comporta como si fuese una máquina independiente. Puede estar totalmente virtualizada utilizando soporte hardware o paravirtualizada emulando parte del hardware subyacente.

El concepto de virtualización empieza en el _mainframe_ IBM/360: el procesador del 360 tenía varios juegos de registros y cambiaba de contexto pasando de ejecutar un juego de registros a otros (incluyendo el program counter, y la pila). El Sistema Operativo del IBM/360 se encargaba de conmutar el contexto del procesador y proteger la memoria por lo que el equipo se comportaba como si hubiese varios ordenadores ejecutándose en el mismo hardware.

Los contenedores son mucho más ligeros que las máquinas virtuales ya que utilizan el kernel del host, en vez de tener que ejecutar varios kernels virtualizados (o emulados).

Todos los procesos de un contenedor se ejecutan en espacio de usuario (userland); sin embargo la máquina virtual además de ejecutar un kernel de un sistema operativo, tiene que ejecutar drivers que le conectan con el hardware.

Por último, el contenedor requiere menos espacio que una máquina virtual porque se aprovechan capas existentes del sistema de archivos y no hay que instalar completamente un sistema operativo: sólo hacen falta los ejecutables, dlls, y si el lenguaje es interpretado también las fuentes.
