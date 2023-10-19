FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
ADD balancerapp/default /etc/nginx/conf.d/default.conf
CMD [ "nginx", "-g" , "daemon off;" ]
