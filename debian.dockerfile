FROM debian:bookworm
COPY debian .
COPY bootstrap.sh .
RUN ./bootstrap.sh
CMD "make"
