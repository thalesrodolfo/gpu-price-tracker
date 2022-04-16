# Get base image

FROM elixir:1.13-alpine
RUN apk upgrade
RUN apk add git

#FROM elixir:latest
#RUN apt-get update 

# create app directory
RUN mkdir /app

# copy all content to this new directory
COPY . /app

# change current directory (like "cd" in shell)
WORKDIR /app

# install hex
RUN mix local.hex --force

# compile the project
RUN mix compile

# execute the module that starts the app
CMD mix run --no-halt -e "PeriodicJob.start()"
