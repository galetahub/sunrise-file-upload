require 'rails/generators'

module Sunrise
  module Generators
    module FileUpload
      class InstallGenerator < Rails::Generators::Base
        desc "This generator downloads and installs FileUploader"
        source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
        
        def copy_javascripts
          copy_file "fileuploader-input.js", 'public/javascripts/fileupload/fileuploader-input.js'
        end
        
        def download_stylesheet
          say_status("fetching fileuploader.css", "", :green)
          get "https://github.com/galetahub/file-uploader/raw/master/client/fileuploader.css", "public/javascripts/fileupload/fileuploader.css"
        end
        
        def download_fileupload
          say_status("fetching fileuploader.js", "", :green)
          get "https://github.com/galetahub/file-uploader/raw/master/client/fileuploader.js", "public/javascripts/fileupload/fileuploader.js"
        end
      end
    end
  end
end
