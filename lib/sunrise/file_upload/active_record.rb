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
            
            attr_accessible :fileupload_guid
            after_save :fileuploads_update, :if => :fileupload_changed?
            
            args.each do |asset|
              accepts_nested_attributes_for asset, :allow_destroy => true
            end
          end
        end
      end
      
      module ClassMethods
        # Update reflection klass by guid
        def fileupload_update(record_id, guid, method)
          klass = reflections[method.to_sym].klass
          klass.update_all(["assetable_id = ?, guid = ?", record_id, nil], ["assetable_type = ? AND guid = ?", name, guid])
        end
      end
      
      module InstanceMethods
        # Generate unique key
        def fileupload_guid
          @fileupload_guid ||= Sunrise::FileUpload.guid
        end
        
        def fileupload_guid=(value)
          @fileupload_changed = true unless value.blank?
          @fileupload_guid = value.blank? ? nil : value
        end
        
        def fileupload_changed?
          @fileupload_changed
        end
        
        protected
        
          def fileuploads_update
            self.class.fileuploads_columns.each do |method|
              self.class.fileupload_update(id, fileupload_guid, method)
            end
          end
      end
      
    end
  end
end
