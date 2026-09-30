FROM alpine
# This image is used as a source for static assets in an init container.
# It contains logos, CSS, and other static files to be served by Payara.

# Create the directory where assets will live in the image
RUN mkdir -p /assets

# Copy all files from the current directory (the persona's static folder) into /assets
COPY . /assets/

# Remove the Dockerfile itself from the assets directory to keep it clean
RUN rm /assets/Dockerfile

# No CMD is strictly needed as the init container in Kubernetes overrides it,
# but we can leave a simple placeholder.
CMD ["ls", "-R", "/assets"]