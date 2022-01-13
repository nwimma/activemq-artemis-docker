FROM openjdk:11
ENV ARTEMIS_JAVA_OPTIONS=""
ENV ARTEMIS_BROKER_HOST=0.0.0.0
ENV ARTEMIS_BROKER_PORT=61616
ENV ARTEMIS_BROKER_NAME=default
ENV ARTEMIS_BROKER_USER=artemis
ENV ARTEMIS_BROKER_PASSWORD=artemis
ENV ARTEMIS_HTTP_HOST=0.0.0.0
ENV ARTEMIS_HTTP_PORT=8161
# download Apache ActiveMQ Artemis and verify the file via gpg
ADD https://downloads.apache.org/activemq/KEYS artemis-keys
RUN gpg --import ./artemis-keys
ADD https://www.apache.org/dyn/closer.cgi?filename=activemq/activemq-artemis/2.20.0/apache-artemis-2.20.0-bin.tar.gz&action=download artemis.tar.gz
ADD https://downloads.apache.org/activemq/activemq-artemis/2.20.0/apache-artemis-2.20.0-bin.tar.gz.asc artemis.tar.gz.asc
RUN gpg --verify ./artemis.tar.gz.asc ./artemis.tar.gz
# put Artemis in a good place (next to the already installed jdk)
RUN mkdir /usr/local/artemis
RUN tar -xzf artemis.tar.gz -C /usr/local/artemis --strip-components=1
ENV ARTEMIS_HOME=/usr/local/artemis
# remove all unneeded files to keep the system clean
RUN rm -rfd artemis-keys artemis.tar.gz artemis.tar.gz.asc
# create a new broker instance
ENV ARTEMIS_INSTANCE=/var/local/lib/artemis-$ARTEMIS_BROKER_NAME
RUN mkdir -p $ARTEMIS_INSTANCE
RUN mkdir /usr/local/etc/artemis-broker
RUN $ARTEMIS_HOME/bin/artemis create --require-login \
--java-options "$ARTEMIS_JAVA_OPTIONS"               \
--host         $ARTEMIS_BROKER_HOST                  \
--default-port $ARTEMIS_BROKER_PORT                  \
--name         "$ARTEMIS_BROKER_NAME"                \
--user         "$ARTEMIS_BROKER_USER"                \
--password     "$ARTEMIS_BROKER_PASSWORD"            \
--http-host    $ARTEMIS_HTTP_HOST                    \
--http-port    $ARTEMIS_HTTP_PORT                    \
--etc          /usr/local/etc/artemis-broker \
--             $ARTEMIS_INSTANCE
CMD $ARTEMIS_INSTANCE/bin/artemis run
