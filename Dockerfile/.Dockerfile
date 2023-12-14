# official Hugo runtime 
FROM klakegg/hugo

# Set the working directory to the Hugo site directory
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .



