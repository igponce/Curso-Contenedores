# chroot

Mecanismo de aislamiento de procesos que cambia el directorio raíz de un proceso, limitando su vista del sistema de archivos.

Se implementa con la llamada al sistema [chroot(2)](https://man.netbsd.org/chroot.2)

```text
/
  /dev
  /etc
  /usr
  /lib
  /mount
    /app1
        /etc
        /bin
        /usr
        /lib
    /app2
        /etc
        /bin
        /usr
        /lib
```

Ventajas:
- Es una forma sencilla de aislar un proceso del resto del sistema, ya que sólo ve el contenido de su 'root'.

Inconvenientes:
- El proceso dentro del chroot no está aislado del sistema.
- Puede "ver" todo el contenido del sistema y hacer llamadas igual que cualquier otro proceso. Si tiene privilegios suficentes puede llegar a matar otros procesos.
- Un proceso puede "escapar" al chroot mediante un hard link -> es necesario que montemos los procesos con chroot en un filesystem aparte.
- Podemos necesitar una copia del sistema (binarios y librerías dinámicas) dentro del chroot para que el proceso pueda funcionar correctamente.
