# Servidor MCP

Vamos a crear un servidor MCP sencillo con Gradio.

Como los LLM no son capaces de saber qué hora es, vamos a crear un MCP que nos diga la hora actual en Madrid, Londres, y Nueva York.

Objetivos:

1. Crear un servidor MCP (utilizando Gradio y vibe conding con Claude/OpenAI/etc.). Necesitaremos Python.
2. Crear un contenedor Docker para el servidor MCP.
3. Ejecutar el contenedor Docker y probar que podemos acceder al servidor MCP desde un agente (Claude code, n8n, Zed...)
