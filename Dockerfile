FROM alpine:latest
LABEL Description="Ubuntu SDV someip SOA Demo"


ENV HOME /home/work

RUN apk update && apk add\
  	build-base \
    	clang \
    	cmake \
    	gdb \
    	git \
    	cmake \
    	vim \
    	wget \
	asciidoc \
	source-highlight \
	doxygen \
	graphviz \
	pkgconfig \
	ca-certificates

RUN mkdir -p /home/work

WORKDIR ${HOME}
	
ARG BOOST_VERSION=1.76.0
ARG BOOST_DIR=boost_1_76_0
ENV BOOST_VERSION ${BOOST_VERSION}

RUN wget http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/${BOOST_DIR}.tar.bz2 \
    && tar --bzip2 -xf ${BOOST_DIR}.tar.bz2 \
    && cd ${BOOST_DIR} \
    && ./bootstrap.sh --prefix=/usr/local \
    && ./b2 install --with=all 
    
RUN apk update
	
WORKDIR ${HOME}

RUN git clone https://github.com/google/googletest && \
	cd googletest && \
	cmake CMakeLists.txt && \
	make && \
	cp ./lib/* /usr/lib && \
	cp -a googletest/include/* /usr/include/ && \
	cp -a googlemock/include/* /usr/include/ 
	
WORKDIR ${HOME}

RUN git clone https://github.com/COVESA/vsomeip.git && \
	cd vsomeip && \
	cmake CMakeLists.txt -DGTEST_ROOT="/home/work/googletest" -Dvsomeip3_DIR="/home/work/vsomeip" && \
	make && \
	make install 
	
WORKDIR ${HOME}    

RUN git clone https://github.com/abhi-306/Vsomeip_MuiltipleClient.git && \
	cp Vsomeip_MuiltipleClient/*.json /home/work/vsomeip/config/ && \
	cp Vsomeip_MuiltipleClient/*.cpp /home/work/vsomeip/examples/ && \
	cp Vsomeip_MuiltipleClient/CMakeLists.txt /home/work/vsomeip/examples/CMakeLists.txt && \
	cd vsomeip && \
	cmake CMakeLists.txt -DGTEST_ROOT="/home/work/googletest" -Dvsomeip3_DIR="/home/work/vsomeip" && \
	make && \
	ldconfig && \
	cmake --build . --target examples 

RUN rm -rf /home/work/boost_1_76_0.tar.bz2 && \
	rm -rf /home/work/boost_1_76_0
	


