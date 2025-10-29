# Elasticsearch configuration
require 'elasticsearch/rails'

elasticsearch_config = Rails.application.config_for(:elasticsearch)

if elasticsearch_config
  Elasticsearch::Model.client = Elasticsearch::Client.new(
    url: elasticsearch_config[:url] || "http://#{elasticsearch_config[:host]}:#{elasticsearch_config[:port]}",
    log: Rails.env.development?
  )
end
