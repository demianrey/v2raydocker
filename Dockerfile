# Usa la imagen base de Alpine Linux para un contenedor ligero
FROM alpine:latest

# Configura el directorio de trabajo
WORKDIR /tmp

# Instala las dependencias necesarias
RUN apk add --no-cache curl unzip ca-certificates && \
    mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray

# Descarga la última versión de V2Ray
RUN curl -L -o v2ray.zip "https://github.com/v2fly/v2ray-core/releases/download/v5.21.0/v2ray-linux-64.zip" && \
    unzip v2ray.zip -d /tmp && \
    mv /tmp/v2ray /usr/bin/v2ray && \
    mv /tmp/geoip.dat /usr/local/share/v2ray/geoip.dat && \
    mv /tmp/geosite.dat /usr/local/share/v2ray/geosite.dat && \
    chmod +x /usr/bin/v2ray && \
    rm -rf /tmp/v2ray.zip

# Copia los archivos de configuración al contenedor
COPY config.json /etc/v2ray/config.json
COPY v2ray.cer /etc/v2ray/v2ray.cer
COPY v2ray.key /etc/v2ray/v2ray.key

# Redirige los logs de V2Ray a stdout y stderr
RUN ln -sf /dev/stdout /var/log/v2ray/access.log && \
    ln -sf /dev/stderr /var/log/v2ray/error.log

# Expone el puerto 443 para Cloud Run
EXPOSE 443

# Configura la variable de entorno PORT para que Cloud Run la use
ENV PORT=443

# Comando de inicio para V2Ray
CMD ["/usr/bin/v2ray", "-config", "/etc/v2ray/config.json"]
