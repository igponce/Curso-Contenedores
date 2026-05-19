# Modelo de distribución

Cuando queremos distribuir un software podemos hacerlo de distintas maneras:

- Paquete local del sistema operativo
  - Debemos elegir un sistema sobre el que se va a ejecutar. 
  - Es necesario crear un ejecutable o ejecutables.
  - El software tiene que seguir unas normas de distribución (Windows, Android, Apple iOS / OSX)
- Appliance
  - El software corre en un sistema hardware cerrado y se vende junto con el hardware que va a ejecutarlo.
  - Es necesario fabricar conseguir un hardware que proporcionar al cliente.
  - 
- Virtual Appliance
  - Imágen de máquina virtual en la que instalamos el software.
  - Por debajo lleva un sistema operativo al que no damos acceso al usuario.
  - Es necesario crear una interfaz de gestión.
  - Es posible que no cubramos todas las necesidades de integración con esta interfaz de gestión.
- Container
  - Se puede ejecutar en un "host" capaz de ejecutar contenedores (Linux, Windows...).
  - El entorno de ejecución es el mismo que en nuestro sistema de desarrollo.
  - Se puede ejecutar y orquestar varios contenedores de forma sencilla sin tener que modificar el interior del contenedor.
  - Cada contenedor tiene lo necesario para un único propósito (librerías, paquetes del SO)
