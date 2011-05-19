module Sunrise
  module FileUpload
    class Manager
      extend Sunrise::FileUpload::Callbacks
      
      def initialize(app, options = {})
        @app = app
        @paths = [options[:paths]].flatten
      end
      
      def call(env)
        raw_file_post?(env) ? create(env) : @app.call(env)
      end
      
      # :api: private
      def _run_callbacks(*args) #:nodoc:
        self.class._run_callbacks(*args)
      end

      protected
      
        def create(env)
          request = Request.new(env)
          params = request.params.symbolize_keys
          
          klass = find_klass(params)
          asset = find_asset(klass, params) || klass.new(params[:asset])
      
        	asset.assetable_type = params[:assetable_type]
		      asset.assetable_id = params[:assetable_id].blank? ? 0 : params[:assetable_id].to_i
		      asset.guid = params[:guid]
        	asset.data = Http.normalize_param(params[:qqfile], request)
          
          _run_callbacks(:before_create, env, asset)
          
          if asset.save
            body = asset.to_json
            status = 200
            
            _run_callbacks(:after_create, env, asset)
          else
            body = asset.errors.to_json
            status = 422
          end
          
          [status, {'Content-Type' => 'text/html', 'Content-Length' => body.size.to_s}, body]
        end
      
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
        
        def raw_file_post?(env)
          env['REQUEST_METHOD'] == 'POST' && upload_path?(env['PATH_INFO'])
        end
        
        def upload_path?(request_path)
          return true if @paths.nil?
          @paths.any? { |candidate| candidate == request_path  }
        end
    end
  end
end
