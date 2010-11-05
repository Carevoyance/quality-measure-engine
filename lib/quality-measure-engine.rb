Bundler.require(:default)

LIB = File.dirname(__FILE__)

require LIB + '/patches/v8'
require LIB + '/nokogiri/namespace_context'

require LIB + '/qme/map/map_reduce_builder'
require LIB + '/qme/map/map_reduce_executor'
require LIB + '/qme/query/json_document_builder'
require LIB + '/qme/query/json_query_executor'

require 'singleton'

require LIB + '/qme/importer/patient_importer'
require LIB + '/qme/importer/code_system_helper'
require LIB + '/qme/importer/hl7_helper'

require 'json'
require 'mongo'
