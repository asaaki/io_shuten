# encoding: utf-8

module IO_shuten
  # IO_shuten::Base is interface class for other implementations.
  class Base

    # Storage of current Base instances of the running process
    # @return [Array]
    @@instances = []

    # Name of current node instance
    # @return [String]
    attr_reader :node_name

    # holds StringIO node
    # @return [StringIO]
    attr :container

    ### class methods

    class << self

      # @return [Array] current instances
      def instances
        @@instances
      end
      alias_method :pool,  :instances
      alias_method :nodes, :instances

      # Deletes ALL instances in the pool!
      #
      # @return [Boolean]
      def purge_instances!
        @@instances = [] and true
      end

      # Deletes a single instance of the pool
      #
      # @param [Base] node instance
      # @param [String] name of node as String
      # @param [Symbol] name of node as Symbol
      def delete_instance node_name_or_instance
        @@instances.delete_if do |node|
          (node_name_or_instance.is_a?(Symbol) && node.node_name == node_name_or_instance) ||
          (node_name_or_instance.is_a?(String) && node.node_name == node_name_or_instance) ||
          (node_name_or_instance.is_a?(Base) && node == node_name_or_instance)
        end
      end


      # Checks for existence of a node
      #
      # @param [String] name of node as String
      # @param [Symbol] name of node as Symbol
      # @return [Boolean]
      def instance_exists? node_name
        # we need to check for node_name, otherwise it will fail though node exists
        !instances.empty? && node_name && instances.map(&:node_name).include?(node_name)
      end
      alias_method :instance_exist?, :instance_exists?
      alias_method :exists?,         :instance_exists?
      alias_method :exist?,          :instance_exists?

    end

    ### instance methods

    # @private
    def respond_to? sym
      !!self.methods.include?(sym) || respond_to_missing?(sym)
    end

    # @private
    def respond_to_missing? sym, include_private = true
      !!container_respond_to?(sym, include_private)
    end

    # @private
    def method_missing method, *args, &block
      if respond_to_missing? method
        @container.send method, *args, &block
      else
        not_yet_implemented! method
      end
    end

  private

    # @private
    def not_yet_implemented! callee = nil, pos = nil
      raise Errors::NotYetImplemented, callee, pos
    end

    # @private
    def container_respond_to? sym, include_private
      @container.respond_to? sym, include_private
    end

  end
end
