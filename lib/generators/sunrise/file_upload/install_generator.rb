require 'rails/generators'
require 'fileutils'

module Sunrise
  module Generators
    module FileUpload
      class InstallGenerator < Rails::Generators::Base
        desc "This generator downloads and installs jQuery-File-Upload"
        source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
        
        def create_directory
          FileUtils.mkdir_p( Rails.root.join('public', 'javascripts', 'fileupload') )
        end
        
        def download_stylesheet
          say_status("fetching jquery.fileupload-ui.css", "", :green)
          get "https://github.com/blueimp/jQuery-File-Upload/raw/master/jquery.fileupload-ui.css", "public/javascripts/fileupload/jquery.fileupload-ui.css"
        end
        
        def download_fileupload
          say_status("fetching jquery.fileupload.js", "", :green)
          get "https://github.com/blueimp/jQuery-File-Upload/raw/master/jquery.fileupload.js", "public/javascripts/fileupload/jquery.fileupload.js"          
        end
        
        def download_fileupload_ui
          say_status("fetching jquery.fileupload-ui.js", "", :green)
          get "https://github.com/blueimp/jQuery-File-Upload/raw/master/jquery.fileupload-ui.js", "public/javascripts/fileupload/jquery.fileupload-ui.js"
        end
      end
    end
  end
end
