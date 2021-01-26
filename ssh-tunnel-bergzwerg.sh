#! /bin/sh

# make a tunnel to "bergzwerg.ddns.net" on port 8181 (where port forwarding is enabled)
# and forward the local port 9999 to port 445 in the remote network
# schematic: local:9999 -> bergzwerg:8181 -> freenas:445

# -L
#     Specifies that connections to the given TCP port or Unix socket on
#     the local (client) host are to be forwarded to the given host and
#     port, or Unix socket, on the remote side.
#     Only the superuser can forward privileged ports.


# -n
#     Prevents reading from stdin. This must be used when ssh is run in
#     the background. (This does not work if ssh needs to ask for a
#     password or passphrase; see also the -f option.)

# -N
#     Do not execute a remote command. This is useful for just forwarding
#     ports.

# -T
#     Disable pseudo-terminal allocation.


ROUTERDOMAINNAME="bergzwerg.ddns.net"

#if [ ! $UID -eq 0 ]; then
#  echo "Only the superuser can forward privileged ports." 1>&2 && exit 1
#fi

ssh ssh://${ROUTERDOMAINNAME}:8181 -nNT -L 9999:localhost:445
