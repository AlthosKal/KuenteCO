FROM nginx:alpine

# Elimina la configuración por defecto
RUN rm /etc/nginx/conf.d/default.conf

# Copia la configuración personalizada
COPY default.conf /etc/nginx/conf.d/

# Copia el contenido estático de Flutter Web
COPY web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
