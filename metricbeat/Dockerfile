FROM docker.elastic.co/beats/metricbeat:8.12.0-arm64

# The file to monitor the host is different from the file to monitor docker services.ADD
# So we pass the filename at build time to choose the target (host or services) of the image built.
ARG METRICBEAT_FILE=metricbeat.yml
COPY ${METRICBEAT_FILE} /usr/share/metricbeat/metricbeat.yml

USER root

RUN apt-get update && \
    apt-get install -y netcat && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/log/metricbeat \
    && chown metricbeat /usr/share/metricbeat/metricbeat.yml \
    && chmod go-w /usr/share/metricbeat/metricbeat.yml \
    && chown metricbeat /var/log/metricbeat

COPY entrypoint.sh /usr/local/bin/custom-entrypoint
RUN chmod +x /usr/local/bin/custom-entrypoint

USER metricbeat

ENTRYPOINT ["/usr/local/bin/custom-entrypoint"]