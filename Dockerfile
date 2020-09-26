FROM rocker/shiny-verse:latest

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    wget

# Add shiny user

# install R packages required
# (change it dependeing on the packages you need)
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse', repos='http://cran.rstudio.com/',dependencies=TRUE)"
RUN R -e "install.packages('RSQLite', repos='http://cran.rstudio.com/',dependencies=TRUE)"
RUN R -e "install.packages('DBI', repos='http://cran.rstudio.com/',dependencies=TRUE)"
RUN R -e "install.packages('ggplot2', repos='http://cran.rstudio.com/',dependencies=TRUE)"
RUN R -e "install.packages('shinythemes', repos='http://cran.rstudio.com/',dependencies=TRUE)"


# copy the app to the image
COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY app.R /srv/shiny-server
COPY data /srv/shiny-server/data/
COPY R /srv/shiny-server/R/

# select port
EXPOSE 3838

# allow permission
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

# run app
CMD ["/usr/bin/shiny-server.sh"]
