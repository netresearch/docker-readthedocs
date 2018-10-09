FROM python:3

ENV RTD_PRODUCTION_DOMAIN 'localhost:8000'

# Prep the environment
RUN apt-get update && apt-get -y install \
  bzr \
  build-essential \
  curl \
  doxygen \
  dvipng \
  g++ \
  git-core \
  graphviz-dev \
  libpq-dev \
  libxml2-dev \
  libxslt-dev \
  libxslt1-dev \
  libfreetype6  \
  libbz2-dev \
  libcairo2-dev \
  libenchant1c2a \
  libevent-dev \
  libffi-dev \
  libfreetype6-dev \
  libgraphviz-dev \
  libjpeg-dev \
  liblcms2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libtiff5-dev \
  libwebp-dev \
  mercurial \
  nginx \
  plantuml \
  postgresql-client \
  subversion \
  texlive-latex-recommended \
  texlive-fonts-recommended \
  texlive-latex-extra \
  pandoc \
  pkg-config \
  wget \
  zlib1g-dev

COPY setup/ /

WORKDIR /var/www/html

# Install readthedocs
RUN wget https://github.com/rtfd/readthedocs.org/archive/master.tar.gz
RUN tar -zxvf master.tar.gz && mv readthedocs.org-master/* .

# Update pip
RUN pip install --upgrade pip

# Install dependencies
RUN pip install git+https://github.com/Supervisor/supervisor
RUN pip install gunicorn setproctitle
RUN pip install -U virtualenv auxlib

# Install the required Python packages
RUN pip install -r requirements.txt

# Create a super user
RUN python manage.py migrate
RUN echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost', 'admin')" | python ./manage.py shell
RUN python manage.py collectstatic --noinput &&\
    python manage.py loaddata test_data

# Set up the gunicorn startup script
RUN chmod u+x ./gunicorn_start.sh

# Clean Up Apt
RUN apt-get autoremove -y

CMD ["supervisord"]
