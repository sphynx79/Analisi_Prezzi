require 'watir'
require 'rautomation'
require 'win32ole' 
require 'timeout'


browser = Watir::Browser.new

browser.goto 'http://www.corriere.it/'

sleep 1

browser.close
