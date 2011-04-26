module Sunrise
  module FileUpload
    module ActiveRecord
      def self.included(base)
        base.send :extend, SingletonMethods
      end
      
      module SingletonMethods
        def fileuploads(*args)
          options = args.extract_options!
          
          class_attribute :fileuploads_options, :instance_writer => false
          self.fileuploads_options = options
          
          class_attribute :fileuploads_columns, :instance_writer => false
          self.fileuploads_columns = args
          
          unless self.is_a?(ClassMethods)
            include InstanceMethods
            extend ClassMethods
            
            attr_writer :fileupload_guid
            
            after_save :update_fileuploads
            
            args.each do |asset|
              accepts_nested_attributes_for asset, :allow_destroy => true
            end
          end
        end
      end
      
      module ClassMethods
        # Update reflection klass by guid
        def update_fileupload(record_id, guid, method)
          klass = self.class.reflections[method.to_sym].klass
          klass.update_all(["assetable_type = ? AND guid = ?", name, guid], ["assetable_id = ?, guid = ?", record_id, nil])
        end
      end
      
      module InstanceMethods
        # Generate unique key
        def fileupload_guid
          @fileupload_guid ||= Sunrise::FileUpload.guid
        end
        
        protected
        
          def update_fileuploads
            self.class.fileuploads_columns.each do |method|
              self.class.update_fileupload(id, fileupload_guid, method)
            end
          end
      end
      
    end
  end
end
