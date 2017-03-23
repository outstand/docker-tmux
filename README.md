## Usage

Run the server:

```sh
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v /bin/docker:/bin/docker --name tmux-server outstand/tmux:latest server
```

Run the client:

```sh
docker run -it --rm --volumes-from tmux-server outstand/tmux:latest client
```
