# Use a lightweight base image
FROM nginx:alpine

# Copy the web application files into the container
COPY index.html /usr/share/nginx/html/

# Expose the web server port
EXPOSE 80

