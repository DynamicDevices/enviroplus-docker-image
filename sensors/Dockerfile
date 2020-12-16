
FROM balenalib/raspberry-pi-python

# Enable OpenRC
ENV INITSYSTEM on 

RUN git clone https://github.com/pimoroni/enviroplus-python && cd enviroplus-python && sudo ./install.sh

COPY scripts/ .

CMD ./autorun.sh
