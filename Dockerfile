# This Dockerfile implements a simple db-less kong for testing

FROM kong:1.2.1-alpine
COPY kong_declarative.yml /etc/kong/
COPY stdout-log /plugins/kong/plugins/stdout-log
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM
CMD ["kong", "docker-start"]
