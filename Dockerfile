# Stage 1: Build Stage
FROM cirrusci/flutter:stable AS build

LABEL maintainer="THARIQ & ISMAIL"

# Set a non-root user to avoid running Flutter as root
RUN adduser -u 1001 --disabled-password --gecos "" flutteruser && \
    mkdir -p /app && \
    chown -R flutteruser:flutteruser /app

# Set ownership of the Flutter SDK to the new user
RUN chown -R flutteruser:flutteruser /sdks/flutter

# Switch to the non-root user
USER flutteruser

# Switch to Flutter version 3.24.1
RUN cd /sdks/flutter && \
    git fetch --all --tags && \
    git checkout 3.24.1 && \
    flutter doctor

# Set the working directory inside the container
WORKDIR /app

# Copy the current project files to the working directory
COPY --chown=flutteruser:flutteruser . /app

# Install Flutter dependencies
RUN flutter pub get

# Build the Flutter project for the web
RUN flutter build web --release

# Stage 2: Runtime Stage
FROM nginx:stable-alpine

# Copy the Flutter web build files from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 for serving the Flutter app
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
