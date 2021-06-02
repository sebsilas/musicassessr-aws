# library imports
library(rjson)
library(tidyverse)
library(shiny)
library(sjmisc)
library(htmltools)
library(psychTestR)
library(rsconnect)
library(readxl)
library(aws.s3)
library(glue)
library(psyquest)
library(promises)
library(future)
library(httr)
library(async)
plan(multisession)
library(stringi)

# install.packages(c('rjson', 'tidyverse', 'shiny', 'sjmisc',
#                    'htmltools', 'psychTestR', 'rsconnect', 'readxl',
#                    'aws.s3', 'glue', 'psyquest', 'promises', 'future', 'httr', 'async', 'stringi'))

# includes
source('constants.R')
source("simile.R")
source('html.R')
source('funs.R')
source('funs_AWS.R')
source('funs_get_answer.R')
source('record_audio_page.R')
source('record_midi_page.R')
source('funs_page_builder.R')
source('microphone_calibration_page.R')
source('transposition.R')
source('present_stimuli.R')
source('present_stimuli_music.R')
source('present_characters.R')
source('present_stimuli_video.R')
source('define_corpus.R')
source('sample_from_corpus.R')
source('preset_corpuses.R')
source('html.R')
source('record_key_presses_page.R')
source('pages_custom.R')








