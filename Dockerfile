FROM rocker/rstudio:3.4.3

## Declares build arguments
ARG NB_USER
ARG NB_UID

COPY --chown=${NB_USER} . ${HOME}

ENV DEBIAN_FRONTEND=noninteractive
USER root
RUN echo "Checking for 'apt.txt'..." \
        ; if test -f "apt.txt" ; then \
        apt-get update --fix-missing > /dev/null\
        && xargs -a apt.txt apt-get install --yes \
        && apt-get clean > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
        ; fi
USER ${NB_USER}

## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi


ENV NB_USER=rstudio

RUN /rocker_scripts/install_jupyter.sh

EXPOSE 8888

CMD ["/bin/sh", "-c", "jupyter lab --ip 0.0.0.0 --no-browser"]

USER ${NB_USER}

WORKDIR /home/${NB_USER}