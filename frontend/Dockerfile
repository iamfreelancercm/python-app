FROM nginx:alpine

# Copy the frontend files
COPY index.html /usr/share/nginx/html/
COPY static/ /usr/share/nginx/html/static/

# Expose port 5000
EXPOSE 5000

# Configure nginx to listen on port 5000
RUN echo 'server { \
    listen 5000; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf
