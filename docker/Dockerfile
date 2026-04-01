# Use lightweight Nginx as the web server
FROM nginx:1.25

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy your UI files into the Nginx web directory
# Make sure your file name matches the actual file (e.g., index.html)
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
