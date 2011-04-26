# encoding: utf-8
require 'digest/sha1'
require 'mime/types'

module Sunrise
  module FileUpload
    # Usage (paperclip example)
    # @asset.data = QqFile.new(params[:qqfile], request)
    class QqFile < ::Tempfile

      def initialize(filename, request, tmpdir = Dir::tmpdir)
        @original_filename  = filename
        @request = request
        
        super Digest::SHA1.hexdigest(filename), tmpdir
        fetch
      end
      
      def self.parse(*args)
        return args.first unless args.first.is_a?(String)
        new(*args)
      end
     
      def fetch
        self.write @request.raw_post
        self.rewind
        self
      end
     
      def original_filename
        @original_filename
      end
     
      def content_type
        types = MIME::Types.type_for(@request.content_type)
	      types.empty? ? @request.content_type : types.first.to_s
      end
    end
  end
end
