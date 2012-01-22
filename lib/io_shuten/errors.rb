# encoding: utf-8

module IO_shuten

  # Collection of Errors/Exceptions
  module Errors

    # Exception if a node object was not found
    class NodeNotFoundError < ::StandardError
    end

    # Exception if the node object name was of wrong type
    class NodeNameError < ::StandardError
    end

    # Exception if the node object name was found in pool
    class NodeExistsError < ::StandardError
    end

    # Exception if file was not found
    class FileNotFoundError < ::StandardError
    end

    # Exception if something went wrong on file handling
    class FileAccessError < ::StandardError
    end

    # Exception for not yet implemented methods (stubs)
    class NotYetImplemented < ::StandardError
      # @private
      def initialize callee = nil, pos = nil
        msg = if callee
          "Method :#{callee} is not (yet) supported. #{pos ? ''+pos+'' : ''}"
        else
          "The method is not (yet) supported."
        end
        super msg
      end
    end

  end
end
