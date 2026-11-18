# Tiny Tails (Python + Docker)

The Python Flask app serves the existing Tiny Tails web interface, including its animal filters, favorites, quiz, and browser speech features.

## Build and run locally

From this directory:

```sh
docker build -t tiny-tails .
docker run --rm -p 8000:8000 tiny-tails
```

Open <http://localhost:8000>. The health endpoint is <http://localhost:8000/health>.

## Run on an Ubuntu EC2 instance

Copy this project directory to the instance (or clone its repository), then run these commands from the project directory:

```sh
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo docker build -t tiny-tails:latest .
sudo docker run -d --name tiny-tails --restart unless-stopped -p 80:8000 tiny-tails:latest
```

Allow inbound TCP port 80 in the instance's security group to make the site publicly reachable. Restrict SSH access to your own IP address. Then open `http://<your-instance-public-ip>/`.

To replace a running container with a newly built image:

```sh
sudo docker rm -f tiny-tails
sudo docker build -t tiny-tails:latest .
sudo docker run -d --name tiny-tails --restart unless-stopped -p 80:8000 tiny-tails:latest
```

The site uses browser speech synthesis and external Wikimedia image URLs, so those features depend on the visitor's browser and internet connection.
