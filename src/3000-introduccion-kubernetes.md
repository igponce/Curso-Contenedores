# De docker-compose a Kubernetes

## Problemas que encontramos en las prácticas

En las dos prácticas anteriores nos encontramos con un problema:

Necesitamos saber las IPs de otros contendores.

- Gitea se tenía que ejecutar detrás de un Proxy (Caddy server)
  - La configuración de Caddy tiene que saber hacia dónde redirigir el tráfico.
  - Esto se puede solventar ejecutando un contenedor que genere la configuración de Caddy.

- N8N necesitaba la IP del Postgres que se usa para la caché de los chats.
  - La única manera de incluirla era creando una conexión en la interfaz gráfica de N8N.
  - Es posible que se pueda crear esta conexión a través de API... pero ¿no hay algo más sencillo
  
¿Cómo podemos descubrir entonces qué contenedores hay ahí fuera? ¿y si hay más de un contenedor?

## Limitaciones de Docker-Compose

- Limitado a un único equipo.
  - Para escalar a varias máquinas es necesario utilizar un componente distinto (docker swarm) que permite tener varios *runners* (máquinas) que ejecutan los contenedores, pero hay que instalarlo y configurarlo aparte.
  - Operaciones
    -  Si un contenedor falla o se muere, no se reinicia automáticamente. Un pipeline de datos que falla a las 3 AM se queda muerto hasta que alguien lo detecte.
  - No hay escalado automático
    - Cuando tus cargas están en la nube, sería deseable poder ejecutar varias réplicas de un mismo servicio de forma dinámica, por ejemplo cuando la CPU supere el 80%.
  - Descubrimiento
    - Los contenedores no pueden descubrirse fácilmente. Necesitas saber IPs, usar variables de entorno o herramientas externas como Consul.
  - Balanceo de carga
    - No basta con docker-compose: necesitas docker-swarm o Kubernetes.
