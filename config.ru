require 'rubygems'
require 'bundler'
require 'sinatra'
require 'rack/coffee'
require './app'

use Rack::Coffee, root: 'public', urls: '/js'

run Sinatra::Application
