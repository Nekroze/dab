FROM node:alpine

RUN apk add --no-cache git \
 && git clone https://github.com/melke/features2html.git /opt/features2html
ENTRYPOINT ["/usr/local/bin/node","/opt/features2html/features2html.js"]
WORKDIR /opt/features2html

VOLUME /usr/src/app/features
VOLUME /usr/src/app/templates
VOLUME /usr/src/app/output
CMD ["--product-name","Dab","--author","Taylor \"Nekroze\" Lawson","--input-dir","/usr/src/app/features","--templates-dir","/usr/src/app/templates","--output-file","/usr/src/app/output/docs.html","create"]
