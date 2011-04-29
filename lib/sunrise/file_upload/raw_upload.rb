module Sunrise
  module FileUpload
    class RawUpload
      def initialize(app, options = {})
        @app = app
        @paths = [options[:paths]].flatten
      end
      
      def call(env)
        kick_in?(env) ? create(env) : @app.call(env)
      end
      
      def upload_path?(request_path)
        return true if @paths.nil?

        @paths.any? do |candidate|
          literal_path_match?(request_path, candidate) || wildcard_path_match?(request_path, candidate)
        end
      end
      
      def create(env)
        request = Request.new(env)
        params = request.params.symbolize_keys
        
        klass = find_klass(params)
        asset = find_asset(klass, params) || klass.new(params[:asset])
    
      	asset.assetable_type = params[:assetable_type]
		    asset.assetable_id = params[:assetable_id] || 0
		    asset.guid = params[:guid]
      	asset.data = QqFile.new(params[:qqfile], request)
      	asset.user = env['warden'].user if env['warden']
        
        if asset.save
          body = asset.to_json
          status = 200
        else
          body = asset.errors.to_json
          status = 422
        end
        
        [status, {'Content-Type' => 'application/json', 'Content-Length' => body.size.to_s}, body]
      end
      
      protected
        
        def find_klass(params)
          params[:klass].blank? ? Asset : params[:klass].classify.constantize
        end
        
        def find_asset(klass, params)
          query = klass.scoped
          
          unless params[:assetable_id].blank? || params[:assetable_type].blank?
            query = query.where(:assetable_id => params[:assetable_id].to_i)
            query = query.where(:assetable_type => params[:assetable_type])
          else
            query = query.where(:guid => params[:guid])
          end
                    
          query.first
        end
        
        def kick_in?(env)
          env['HTTP_X_FILE_UPLOAD'] == 'true' && raw_file_post?(env)
        end
        
        def raw_file_post?(env)
          upload_path?(env['PATH_INFO']) && env['REQUEST_METHOD'] == 'POST'
        end
        
        def literal_path_match?(request_path, candidate)
          candidate == request_path
        end

        def wildcard_path_match?(request_path, candidate)
          return false unless candidate.include?('*')
          regexp = '^' + candidate.gsub('.', '\.').gsub('*', '[^/]*') + '$'
          !! (Regexp.new(regexp) =~ request_path)
        end
    end
  end
end
