FROM r-base:4.2.2

ENV RENV_VERSION 0.16.0
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR /project

COPY renv.lock renv.lock
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.dcf renv/settings.dcf
RUN R -e "renv::restore()"

# a hack to force to rebuild below layers
ARG CODE_VER 	
RUN echo $CODE_VER

COPY data/ data/
COPY main.R . 

ENTRYPOINT ["Rscript", "main.R"]