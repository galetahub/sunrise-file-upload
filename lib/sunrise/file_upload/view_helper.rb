module Sunrise
  module FileUpload
    module ViewHelper
      include ActionView::Helpers::JavaScriptHelper
      
      def fileupload_tag(object_name, method, options = {})
        object = options.delete(:object) if options.key?(:object)
        object ||= @template.instance_variable_get("@#{object_name}")
        
        value = options.delete(:value) if options.key?(:value)
        value ||= object.send(method) || object.send("build_#{method}")
        
        element_guid = object.fileupload_guid
        element_id = dom_id(object, [method, element_guid].join('_'))
        
        script_options = (options.delete(:script) || {}).stringify_keys
        
        params = {
          :klass => value.class.name, 
          :assetable_id => object.new_record? ? 0 : object.id, 
          :assetable_type => object.class.name,
          :guid => element_guid
        }.merge(script_options.delete(:params) || {})
        
        script_options['action'] ||= '/sunrise/fileupload?' + Rack::Utils.build_query(params)
        script_options['allowedExtensions'] ||=  ['jpg', 'jpeg', 'png', 'gif']
        
        content_tag(:div, :class => 'fileupload') do
          content_tag(:div, :id => element_id) do
            content_tag(:noscript) do
              fields_for method, value do |f|
                f.file_field :data
              end
            end
          end + javascript_tag( fileupload_script(element_id, value, script_options) )
        end
      end
      
      protected
      
        def fileupload_script(element_id, value = nil, options = {})
          options = { 'element' => element_id }.merge(options)
          formatted_options = options.inspect.gsub('=>', ':')
          js = [ "new qq.FileUploaderInput(#{formatted_options});" ]
          
          if value && !value.new_record?
            js << "qq.FileUploader.instances['#{element_id}']._updatePreview(#{value.to_json});"
          end
          
          "$(document).ready(function(){ #{js.join} });"
        end
      
    end
  end
end
