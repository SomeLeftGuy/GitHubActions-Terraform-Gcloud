FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
ADD default /etc/nginx/conf.d/default.conf
CMD [ "nginx", "-g" , "daemon off;" ]