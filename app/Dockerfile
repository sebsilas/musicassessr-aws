FROM rocker/shiny:latest
# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev
## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean
# copy necessary files
## app folder
COPY /source_code ./app


RUN Rscript -e 'install.packages(c("rjson", "tidyverse", "shiny", "sjmisc", "htmltools", "psychTestR", "rsconnect", "readxl", "aws.s3", "glue", "psyquest", "promises", "future", "httr", "async", "stringi"))'

CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
