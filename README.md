# docker-go2

Build the environemnt with ros humble:

```
# Build the humble environemnt (or foxy) 
docker compose build go2-humble
```

Run the container
```
cd ~/docker-go2/

# First time run the following (or go2-foxy)
docker compose up go2-humble -d

# Then start the container with humble or foxy distro
docker compose exec -it go2-humble bash
```
