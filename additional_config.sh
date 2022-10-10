

# setup Docker
sudo groupadd docker
sudo usermod -aG docker $USER

sudo setfacl --modify user:`whoami`:rw /var/run/docker.sock

# setup Rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

