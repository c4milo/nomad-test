FROM centos:6

RUN yum install -y \
	epel-release \
	wget \
	rpm \
	unzip \
	centos-release-SCL \
	ca-certificates \
	gsl \
	blas-devel \
	lapack-devel \
	libxslt-devel

RUN yum install -y \
	python-pip \
	python-devel

RUN pip install --upgrade pip Flask
RUN pip install uwsgi

WORKDIR /app
COPY . /app

RUN python -m compileall /app
CMD ["python /app/app.py"]
