FROM gcr.io/dropviz-181317/dropviz-shiny-server
ARG BRANCH=master
MAINTAINER dkulp@broadinstitute.org
RUN rm -r /srv/shiny-server
WORKDIR /srv/shiny-server

RUN git clone https://github.com/broadinstitute/dropviz.git .
RUN git checkout $BRANCH
RUN mkdir -p www/cache/metacells

RUN chmod -R a+rwx www

RUN echo "dropviz-bookmarks /var/lib/shiny-server/bookmarks/ gcsfuse rw,uid=999,gid=999" >> /etc/fstab
COPY image/shiny-server.sh /bin
RUN chmod +x /bin/shiny-server.sh
CMD /bin/shiny-server.sh

# workaround for #60
RUN apt-get update
RUN apt-get install -y libcurl4-openssl-dev libxml2-dev libssl-dev
RUN R -e "install.packages('devtools', repos = 'http://cran.us.r-project.org'); library('devtools'); install_github('jrnold/ggthemes')"

EXPOSE 80

# debug:
RUN echo "preserve_logs true;" >> /etc/shiny-server/shiny-server.conf

# start image with full privs on GCE console and these mount points
#docker run -d --privileged
#              -v /mnt/disks/dropseq/staged/:/cache/ 
#              -v /mnt/disks/dropseq/atlas_ica/:/atlas_ica/ 