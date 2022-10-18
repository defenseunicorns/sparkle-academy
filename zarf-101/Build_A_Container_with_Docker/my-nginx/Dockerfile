# Set the base image to be the upstream nginx image
FROM nginx

# We want to be able to ping other containers, let's install
# the package to allow that to happen
RUN apt update && apt install -y iputils-ping

# Copy the custom index.html page in to the root HTML directory
COPY index.html /usr/share/nginx/html/

# Copy the custom nginx configuration into the /etc/nginx/ 
# directory.  This is required to change the port inside the 
# container that nginx is listenting to (default is 80).
COPY nginx.conf /etc/nginx/

# Change the port that container exposes to match what is in 
# the new nginx.conf file.
EXPOSE 8080

# Adding an instruction to the Dockerfile to see how it 
# affects the build
RUN touch /usr/share/nginx/html/some_other_index.html

CMD ["nginx", "-g", "daemon off;"]
