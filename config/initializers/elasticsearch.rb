# Elasticsearch configuration
begin
  require 'elasticsearch/rails'
  
  elasticsearch_config = Rails.application.config_for(:elasticsearch)
  
  if elasticsearch_config
    Elasticsearch::Model.client = Elasticsearch::Client.new(
      url: elasticsearch_config[:url] || "http://#{elasticsearch_config[:host]}:#{elasticsearch_config[:port]}",
      log: Rails.env.development?
    )
  end
rescue LoadError => e
  Rails.logger.info "Elasticsearch not available: #{e.message}"
rescue => e
  Rails.logger.warn "Elasticsearch configuration error: #{e.message}"
end
