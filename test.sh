#!/bin/bash -xe
test_image() {
    IMAGE=$1
    ./atomic uninstall ${IMAGE} || true
    ./atomic install ${IMAGE}
    ./atomic uninstall ${IMAGE}
    ./atomic info ${IMAGE}
    ./atomic run --spc ${IMAGE} /bin/ps
    ./atomic run ${IMAGE} /bin/ps
    ./atomic run --name=atomic_test ${IMAGE} sleep 6000 &
    ./atomic run --name=atomic_test ${IMAGE} ps 
    ./atomic version ${IMAGE}
    ./atomic uninstall --name=atomic_test ${IMAGE}
}
test_image busybox
test_image fedora

cat > Dockerfile <<EOF
FROM busybox
EOF
docker build -t atomic_busybox .
./atomic info atomic_busybox
./atomic version atomic_busybox
cat > Dockerfile <<EOF
FROM busybox
LABEL RUN /usr/bin/docker run -ti --rm IMAGE /bin/echo RUN
LABEL INSTALL /usr/bin/docker run -ti --rm IMAGE /bin/echo INSTALL
LABEL UNINSTALL /usr/bin/docker run -ti --rm IMAGE /bin/echo UNINSTALL
LABEL Name Atomic Busybox
LABEL Version 1.0
LABEL Release 1.0
EOF
docker build -t atomic_busybox .
./atomic run atomic_busybox | grep RUN
./atomic install atomic_busybox | grep INSTALL
./atomic version atomic_busybox | grep Atomic
./atomic uninstall atomic_busybox | grep UNINSTALL
rm -f Dockerfile
./atomic uninstall busybox
