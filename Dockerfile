# Create the container from the alpine linux image
FROM alpine:3.7

# Add nginx and nodejs
RUN apk add --update nginx nodejs

# Create the directories we will need
RUN mkdir -p /tmp/nginx/vue
RUN mkdir -p /var/log/nginx
RUN mkdir -p /var/www/html/dist
RUN mkdir -p /var/www/html/src/assets

# Copy the respective nginx configuration files
COPY nginx_config/nginx.conf /etc/nginx/nginx.conf
COPY nginx_config/default.conf /etc/nginx/conf.d/default.conf

# Set the directory we want to run the next commands for
WORKDIR /tmp/nginx/vue
# COPY our source code into the container
COPY . .
# Install the dependencies, can be commented out if you're running the same node version
RUN npm install

# Run webpack and the vue-loader
RUN npm run build

# Copy the built app to our served directory
RUN cp -r ./dist/* /var/www/html/dist
RUN cp ./src/assets/us-states.json /var/www/html/src/assets
RUN cp ./index.html /var/www/html

# Make all files belong to the nginx user
RUN chown -R nginx:nginx /var/www/html

# Start nginx and keep the process from backgrounding and the container from quitting
CMD ["nginx", "-g", "daemon off;"]
