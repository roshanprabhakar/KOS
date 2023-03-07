ops="--rm -it -v $(PWD):/root/kmew2 --security-opt seccomp=unconfined"
img="kmew2-env"
cmd="docker run $ops $img"

echo "$cmd"
$cmd
